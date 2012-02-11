; -*- mode: lisp; package: xl-open-uri.test.protocols.http.delete; encoding: shift_jis -*-

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

(defpackage :xl-open-uri.test.protocols.http.delete
  (:use :lisp :editor
   :lisp-unit
   :json
   :http-client
   :xl-open-uri
   :xl-open-uri.test.helper
   )
  )

(in-package :xl-open-uri.test.protocols.http.delete)

(remove-all-tests :xl-open-uri.test.protocols.http.delete)

(define-test http-delete
  (with-open-uri (s "http://localhost:3000/snoop"
                    :method :delete)
    (assert-equal (values 200 "OK")
        (status s))
    (assert-equal "application/json; charset=utf-8"
        (meta s "content-type"))
    (let ((json (json-decode (read-all s))))
      (assert-equal "DELETE" ($ json "method"))
      (assert-equal nil ($ json "query"))
      (assert-equal nil ($ json "body"))
      (assert-equal (format nil "xyzzy/~A" (software-version))
          ($ json "headers" "user-agent"))
      )
    )
  )

(define-test http-delete/headers
  (with-open-uri (s "http://localhost:3000/snoop"
                    :method :delete
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

(define-test http-delete/query
  (with-open-uri (s "http://localhost:3000/snoop"
                    :method :delete
                    :query '((q "xyzzy 読み方") (num 50))
                    :encoding *encoding-sjis*)
    (let ((json (json-decode (read-all s))))
      (assert-equal "xyzzy%20%93%C7%82%DD%95%FB" ($ json "query" "q"))
      (assert-equal "50" ($ json "query" "num"))
      )
    )
  )

(define-test http-delete/no-redirect
  (with-open-uri (s "http://localhost:3000/redirect?url=http://localhost:3000/snoop&status=301"
                    :method :delete)
    (assert-equal (values 200 "OK")
        (status s))
    (assert-equal "DELETE" ($ (json-decode (read-all s)) "method")))
  (with-open-uri (s "http://localhost:3000/redirect?url=http://localhost:3000/snoop&status=302"
                    :method :delete)
    (assert-equal (values 200 "OK")
        (status s))
    (assert-equal "DELETE" ($ (json-decode (read-all s)) "method")))
  (with-open-uri (s "http://localhost:3000/redirect?url=http://localhost:3000/snoop&status=301"
                    :method :delete
                    :no-redirect t)
    (read-all s) ; wait for response
    (assert-equal (values 301 "Moved Permanently")
        (status s))
    (assert-equal "http://localhost:3000/snoop"
        (meta s "Location")))
  (with-open-uri (s "http://localhost:3000/redirect?url=http://localhost:3000/snoop&status=302"
                    :method :delete
                    :no-redirect t)
    (read-all s) ; wait for response
    (assert-equal (values 302 "Moved Temporarily")
        (status s))
    (assert-equal "http://localhost:3000/snoop"
        (meta s "Location")))
  )
