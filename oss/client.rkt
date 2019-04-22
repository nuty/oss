#lang racket
(require 
  gregor
  net/base64
  net/http-client
  sha
  (only-in file/sha1
    hex-string->bytes))

(define base-oss%
  (class object%
    (super-new)

    (abstract make-signature)
    (abstract make-url)
    (abstract put-object)
    (abstract make-headers)
    (abstract make-request)

    (init-field 
      access-key-id
      access-key-secret
      end-point)))
 

(define (gmt)
  (let ([gmt (parameterize ([current-locale "en"])
    (~t (now/utc) "E, d MMM y HH:mm:ss "))])
  (string-append gmt "GMT")))

(define current-gmt-time (gmt))

(define oss-clent%
  (class base-oss%
    (super-new)

    (define/override (make-signature method type bucket object)
      (let 
        ([s-key (get-field access-key-secret this)])
          (let ([sign-data (string-join (list method "\n\n" type "\n"  current-gmt-time "\n" "/" bucket "/" object) "")])
            (bytes->string/utf-8 
              (base64-encode
                (hex-string->bytes
                  (bytes->hex-string
                    (hmac-sha1
                      (string->bytes/utf-8
                        (get-field access-key-secret this))
                          (string->bytes/utf-8 sign-data)))))))))

    (define/override (make-headers bucket object method url)
      (define type 
        (cond 
          [(eq? method "PUT")  "application/x-www-form-urlencoded"]
          [(eq? method "DELETE")  "application/x-www-form-urlencoded"]))

        (list
          (string-join (list "Host: " url) "")
          (string-join (list "Date: " current-gmt-time) "")
          (string-join (list "Content-Type: " type) "")
          (string-join (list "Authorization: OSS " 
                        (get-field access-key-id this) ":" (send this make-signature method type bucket object)) "")))


    (define/override (make-request url method bucket object content)
      (define-values (status headers in)
        (http-sendrecv 
          url
          (string-append "/" object)
          #:method method
          #:ssl? #f
          #:headers (send this make-headers bucket object method url)
          #:data content))
        (displayln status)
        (displayln (port->string in))
        (close-input-port in))

    (define/override (put-object bucket content object [method "PUT"])
      (define endpoint (get-field end-point this))
      (send this make-request  
        (send this make-url bucket endpoint) 
        method
        bucket
        object 
        content))
    
    (define/override (make-url bucket endpoint)
        (string-join (list bucket "." endpoint) ""))))


(define (client access-key-id access-key-secret end-point)
  (make-object oss-clent% access-key-id access-key-secret end-point))


(provide  
    current-gmt-time
    client)