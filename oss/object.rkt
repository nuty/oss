#lang racket
(define (object-put oss-client bucket content object)
  (send oss-client put-object bucket content object))

(define (object-delete oss-client bucket object) (void))

(define (object-get oss-client bucket object) (void))

(define (object-post oss-client bucket content object) (void))



(provide 
  object-put)