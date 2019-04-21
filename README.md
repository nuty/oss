## OSS

一个简单的阿里云OSS SDK

不完善 **刚开始写**!


## 安装

```
raco pkg install https://github.com/nuty/racket-oss.git
```


## 使用

```racket
#lang racket

(require oss)

(define oss-client 
    (client  "access-key-id" "access-key-secret" "end-point"))

(define (read-file path [limit 1000])
    (call-with-input-file
      path
        (lambda (in) (read-string limit in))))


(define content 
    (read-file (string-join (list (path->string (current-directory)) "test.file") "")))

(object-put oss-client "bucket" content "test.file")
```
