## OSS

一个简单的阿里云OSS SDK

不完善 **刚开始写**!


## 安装

```
raco pkg install https://github.com/nuty/oss.git
```


## 使用

```racket
#lang racket

(require oss)

(define oss-client 
    (client  "access-key-id" "access-key-secret" "end-point"))

(define content 
    (file->bytes (string-join (list (path->string (current-directory)) "test.file") "")))

(object-put oss-client "bucket" content "test.file")
```