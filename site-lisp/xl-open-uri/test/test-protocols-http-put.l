; -*- mode: lisp; package: xl-open-uri.test.protocols.http.put; encoding: shift_jis -*-

;; Copyright (c) 2012 MIYAMUKO Katsuyuki.
;;
;; Permission is hereby granted, free of charge, to any person obtaining
;; a copy of this software and associated documentation files (the
;; "Software"), to deal in the Software without restriction, including
;; without limitation the rights to use, copy, modify, merge, publish,
;; distribute, sublicense, and/or sell copies of the Software, and to
;; permit persons to whom the Software is furnished to do so, subject to
;; the following conditions:
;;
;; The above copyright notice and this permission notice shall be
;; included in all copies or substantial portions of the Software.
;;
;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
;; EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
;; MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
;; NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
;; LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
;; OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
;; WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

;;
;; https://github.com/miyamuko/node-test-httpd を利用したテスト。
;;

;;; Code:

(require "lisp-unit")

(require "json")
(require "http-client")
(require "xl-open-uri")
(require "xl-open-uri/test/helper")

(defpackage :xl-open-uri.test.protocols.http.put
  (:use :lisp :editor
   :lisp-unit
   :json
   :http-client
   :xl-open-uri
   :xl-open-uri.test.helper
   )
  )

(in-package :xl-open-uri.test.protocols.http.put)

(remove-all-tests :xl-open-uri.test.protocols.http.put)

(define-test http-put
  (with-open-uri (s "http://localhost:3000/snoop"
                    :method :put)
    (assert-equal (values 200 "OK")
        (status s))
    (assert-equal "application/json; charset=utf-8"
        (meta s "content-type"))
    (let ((json (json-decode (read-all s))))
      (assert-equal "PUT" ($ json "method"))
      (assert-equal nil ($ json "query"))
      (assert-equal nil ($ json "body"))
      (assert-equal (format nil "xyzzy/~A" (software-version))
          ($ json "headers" "user-agent"))
      )
    )
  )

(define-test http-put/headers
  (with-open-uri (s "http://localhost:3000/snoop"
                    :method :put
                    :headers `(:X-Yzzy-Version ,(software-version)
                               :X-Hoge 1
                               :X-Hoge 2
                               :X-Hoge 3))
    (let ((json (json-decode (read-all s))))
      (assert-equal (software-version) ($ json "headers" "X-Yzzy-Version"))
      ;; Express がまとめてる?
      (assert-equal "1, 2, 3" ($ json "headers" "X-Hoge"))
      )
    )
  )

(define-test http-put/query
  (with-open-uri (s "http://localhost:3000/snoop"
                    :method :put
                    :query '((q "xyzzy 読み方") (num 50))
                    :encoding *encoding-sjis*)
    (let ((json (json-decode (read-all s))))
      (assert-equal "xyzzy%20%93%C7%82%DD%95%FB" ($ json "query" "q"))
      (assert-equal "50" ($ json "query" "num"))
      )
    )
  )

(define-test http-put/no-redirect
  (with-open-uri (s "http://localhost:3000/redirect?url=http://localhost:3000/snoop&status=301"
                    :method :put)
    (assert-equal (values 200 "OK")
        (status s))
    (assert-equal "PUT" ($ (json-decode (read-all s)) "method")))
  (with-open-uri (s "http://localhost:3000/redirect?url=http://localhost:3000/snoop&status=302"
                    :method :put)
    (assert-equal (values 200 "OK")
        (status s))
    (assert-equal "PUT" ($ (json-decode (read-all s)) "method")))

  (with-open-uri (s "http://localhost:3000/redirect?url=http://localhost:3000/snoop&status=301"
                    :method :put
                    :no-redirect t)
    (read-all s) ; wait for response
    (assert-equal (values 301 "Moved Permanently")
        (status s))
    (assert-equal "http://localhost:3000/snoop"
        (meta s "Location")))
  (with-open-uri (s "http://localhost:3000/redirect?url=http://localhost:3000/snoop&status=302"
                    :method :put
                    :no-redirect t)
    (read-all s) ; wait for response
    (assert-equal (values 302 "Moved Temporarily")
        (status s))
    (assert-equal "http://localhost:3000/snoop"
        (meta s "Location")))
  )

(define-test http-put/urlencoded
  (with-open-uri (s "http://localhost:3000/snoop"
                    :method :put
                    :body '((name1 "hoge")
                            (name2 "fuga")))
    (let ((json (json-decode (read-all s))))
      (assert-equal '(("name1" . "hoge")
                      ("name2" . "fuga"))
          ($ json "body"))
      (assert-equal "application/x-www-form-urlencoded"
          ($ json "headers" "content-type"))
      (assert-equal "21"
          ($ json "headers" "content-length"))
      ))
  )

(define-test http-put/multipart
  (with-open-uri (s "http://localhost:3000/snoop"
                    :method :put
                    :body '((name1 :value "hoge")
                            (name2 :value "fuga")))
    (let ((json (json-decode (read-all s))))
      (assert-equal '(("name1" . "hoge")
                      ("name2" . "fuga"))
          ($ json "body"))
      (assert-string-match "^multipart/form-data; boundary=.+?$"
          ($ json "headers" "content-type"))
      ))
  )

(define-test http-put/file-upload
  (with-open-uri (s "http://localhost:3000/snoop"
                    :method :put
                    :body '((file1 :file "test-file.zip")
                            (file2 :file "test-file-crlf-sjis.bin")
                            (name1 "hoge")
                            (name2 "fuga")))
    (let ((json (json-decode (read-all s))))
      (assert-equal '(("name1" . "hoge")
                      ("name2" . "fuga"))
          ($ json "body"))
      (let ((path ($ json "files" "file1" "path")))
        (assert-equal
            (md5-file "test-file.zip")
            (md5-file path))
        (delete-file path))
      (let ((path ($ json "files" "file2" "path")))
        (assert-equal
            (md5-file "test-file-crlf-sjis.bin")
            (md5-file path))
        (delete-file path))
      ))
  )
