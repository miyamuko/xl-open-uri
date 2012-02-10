; -*- mode: lisp; package: xl-open-uri.test.protocols; encoding: shift_jis -*-

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

(require "xl-open-uri")
(require "xl-open-uri/test/helper")

(defpackage :xl-open-uri.test.protocols
  (:use :lisp :editor
   :lisp-unit
   :xl-open-uri.protocols
   )
  )

(in-package :xl-open-uri.test.protocols)

(remove-all-tests :xl-open-uri.test.protocols)

(define-test add-protocol-handler
  (let ((xl-open-uri.core::*protocol-handler-alist* nil))
    (add-protocol-handler :https :xl-open-uri.test.protocols)
    (assert-equal '((:https . :xl-open-uri.test.protocols))
        xl-open-uri.core::*protocol-handler-alist*))

  (let ((xl-open-uri.core::*protocol-handler-alist* nil))
    (add-protocol-handler 'https (find-package "xl-open-uri.test.protocols"))
    (assert-equal '((:https . :xl-open-uri.test.protocols))
        xl-open-uri.core::*protocol-handler-alist*))

  (let ((xl-open-uri.core::*protocol-handler-alist* nil))
    (add-protocol-handler "https" "xl-open-uri.test.protocols")
    (assert-equal '((:https . :xl-open-uri.test.protocols))
        xl-open-uri.core::*protocol-handler-alist*))
  )

(define-test find-protocol-handler
  (let ((xl-open-uri.core::*protocol-handler-alist* nil))
    (add-protocol-handler :https :xl-open-uri.test.protocols)
    (add-protocol-handler :http :xl-open-uri.test.protocols)
    (assert-equal :xl-open-uri.test.protocols
        (find-protocol-handler :https))
    (assert-equal :xl-open-uri.test.protocols
        (find-protocol-handler 'https))
    (assert-equal :xl-open-uri.test.protocols
        (find-protocol-handler "https"))

    (add-protocol-handler "https" :xl-open-uri)
    (assert-equal :xl-open-uri
        (find-protocol-handler :https))
    (assert-equal :xl-open-uri
        (find-protocol-handler 'https))
    (assert-equal :xl-open-uri
        (find-protocol-handler "https"))
    )
  )

(define-test remove-protocol-handler
  (let ((xl-open-uri.core::*protocol-handler-alist* nil))
    (add-protocol-handler :https :xl-open-uri.test.protocols)
    (add-protocol-handler :http :xl-open-uri.test.protocols)
    (assert-equal 2 (length xl-open-uri.core::*protocol-handler-alist*))

    (remove-protocol-handler :https)
    (assert-equal 1 (length xl-open-uri.core::*protocol-handler-alist*))

    (remove-protocol-handler :http)
    (assert-equal 0 (length xl-open-uri.core::*protocol-handler-alist*))

    (remove-protocol-handler :https)
    (remove-protocol-handler :http)
    (assert-equal 0 (length xl-open-uri.core::*protocol-handler-alist*))
    )
  )

(define-test parse-media-type
  (assert-equal nil (parse-media-type nil))
  (assert-equal nil (parse-media-type ""))

  (assert-equal (values "text/html" nil nil)
      (parse-media-type "text/html"))
  (assert-equal (values "text/html" "utf-8" *encoding-utf8n*)
      (parse-media-type "text/html;charset=utf-8"))
  (assert-equal (values "text/html" "utf-8" *encoding-utf8n*)
      (parse-media-type "text/html;charset=UTF-8"))
  (assert-equal (values "text/html" "utf-8" *encoding-utf8n*)
      (parse-media-type "text/html;charset=\"UTF-8\""))
  (assert-equal (values "text/html" "utf-8" *encoding-utf8n*)
      (parse-media-type "text/html;  charset=\"UTF-8\""))
  (assert-equal (values "text/html" "utf-8" *encoding-utf8n*)
      (parse-media-type "TEXT/HTML;  CHARSET=\"UTF-8\""))

  (assert-equal (values "text/html" "shift_jis" *encoding-sjis*)
      (parse-media-type "text/html; charset=shift_jis"))
  (assert-equal (values "text/html" "euc-jp" *encoding-euc-jp*)
      (parse-media-type "text/html; charset=EUC-JP"))
  )

(define-test split-token
  (assert-equal nil (split-token nil))
  (assert-equal nil (split-token ""))
  (assert-equal '("gzip") (split-token "gzip"))
  (assert-equal '("gzip" "deflate") (split-token "gzip, deflate"))
  (assert-equal '("gzip" "deflate") (split-token "gzip,deflate"))
  (assert-equal '("gzip" "deflate") (split-token "  gzip  ,  deflate  "))
  (assert-equal '("gzip" "deflate" "identity") (split-token "gzip; deflate; identity" #\;))
  )
