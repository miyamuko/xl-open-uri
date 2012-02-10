; -*- mode: lisp; package: xl-open-uri.test.protocols.http.get; encoding: shift_jis -*-

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

;;; Code:

(require "lisp-unit")

(require "json")
(require "xl-open-uri")
(require "xl-open-uri/test/helper")

(defpackage :xl-open-uri.test.protocols.http.get
  (:use :lisp :editor
   :lisp-unit
   :json
   :xl-open-uri
   :xl-open-uri.test.helper
   )
  )

(in-package :xl-open-uri.test.protocols.http.get)

(remove-all-tests :xl-open-uri.test.protocols.http.get)

(define-test http-user-agent/get
  (multiple-value-bind (body status headers uri)
      (let ((*http-user-agent* "hoge"))
        (http-response-values
         (http-get "http://localhost:3000/snoop")))
    (let ((json (json-decode body)))
      (assert-equal "hoge"
          ($ json "headers" "user-agent"))
      )
    )
  )

(define-test http-user-agent/post
  (multiple-value-bind (body status headers uri)
      (http-response-values
       (http-post "http://localhost:3000/snoop" nil
                  :headers `(:User-Agent "fuga")))
    (let ((json (json-decode body)))
      (assert-equal "fuga"
          ($ json "headers" "user-agent"))
      )
    )
  )
