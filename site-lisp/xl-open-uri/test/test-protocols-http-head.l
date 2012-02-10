; -*- mode: lisp; package: xl-open-uri.test.protocols.http.head; encoding: shift_jis -*-

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

(defpackage :xl-open-uri.test.protocols.http.head
  (:use :lisp :editor
   :lisp-unit
   :json
   :http-client
   :xl-open-uri
   :xl-open-uri.test.helper
   )
  )

(in-package :xl-open-uri.test.protocols.http.head)

(remove-all-tests :xl-open-uri.test.protocols.http.head)

(define-test http-head
  (with-open-uri (s "http://localhost:3000/snoop"
                    :method :head)
    (assert-equal (values 200 "OK")
        (status s))
    (assert-equal "application/json; charset=utf-8"
        (meta s "content-type"))
    (assert-equal :eof
        (read-all s nil nil :eof))
    )
  )

(define-test http-head/headers
  (with-open-uri (s "http://localhost:3000/snoop"
                    :method :head
                    :headers `(:X-Yzzy-Version ,(software-version)
                               :X-Hoge 1
                               :X-Hoge 2
                               :X-Hoge 3))
    (assert-equal :eof
        (read-all s nil nil :eof))
    )
  )

(define-test http-head/query
  (with-open-uri (s "http://localhost:3000/snoop"
                    :method :head
                    :query '((q "xyzzy 読み方") (num 50))
                    :encoding *encoding-sjis*)
    (assert-equal :eof
        (read-all s nil nil :eof))
    )
  )

(define-test http-head/no-redirect
  (with-open-uri (s "http://localhost:3000/redirect?url=http://localhost:3000/snoop&status=301"
                    :method :head)
    (assert-equal (values 200 "OK")
        (status s))
    (assert-equal :eof
        (read-all s nil nil :eof)))
  (with-open-uri (s "http://localhost:3000/redirect?url=http://localhost:3000/snoop&status=302"
                    :method :head)
    (assert-equal (values 200 "OK")
        (status s))
    (assert-equal :eof
        (read-all s nil nil :eof)))
  (with-open-uri (s "http://localhost:3000/redirect?url=http://localhost:3000/snoop&status=301"
                    :method :head
                    :no-redirect t)
    (assert-equal (values 301 "Moved Permanently")
        (status s))
    (assert-equal "http://localhost:3000/snoop"
        (meta s "Location"))
    (assert-equal :eof
        (read-all s nil nil :eof)))
  (with-open-uri (s "http://localhost:3000/redirect?url=http://localhost:3000/snoop&status=302"
                    :method :head
                    :no-redirect t)
    (assert-equal (values 302 "Moved Temporarily")
        (status s))
    (assert-equal "http://localhost:3000/snoop"
        (meta s "Location"))
    (assert-equal :eof
        (read-all s nil nil :eof)))
  )
