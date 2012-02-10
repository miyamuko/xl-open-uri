; -*- mode: lisp; package: xl-open-uri.test.close; encoding: shift_jis -*-

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

(defpackage :xl-open-uri.test.close
  (:use :lisp :editor
   :lisp-unit
   :xl-open-uri
   :xl-open-uri.test.helper
   )
  )

(in-package :xl-open-uri.test.close)

(remove-all-tests :xl-open-uri.test.close)

(define-test close-uri
  (let ((xl-open-uri.core::*stream-context* (make-hash-table))
        (xl-open-uri.core::*cleanup-waiting* nil))
    (let ((s1 (open-uri "data:,A%20brief%20note"))
          (s2 (open-uri "data:,A%20brief%20note")))
      (assert-eql 2 (hash-table-count xl-open-uri.core::*stream-context*))

      (close-uri s1)
      (assert-eql 1 (hash-table-count xl-open-uri.core::*stream-context*))

      (close s2)
      (assert-eql 1 (hash-table-count xl-open-uri.core::*stream-context*))

      (close-uri s2)
      (assert-eql 0 (hash-table-count xl-open-uri.core::*stream-context*))
      ))
  )

(define-test close-uri/cleanup
  (let ((xl-open-uri.core::*stream-context* (make-hash-table))
        (xl-open-uri.core::*cleanup-waiting* nil))
    (let ((s1 (open-uri "data:,A%20brief%20note"))
          (s2 (open-uri "data:,A%20brief%20note"))
          (callback-arg nil))
      (assert-eql 2 (hash-table-count xl-open-uri.core::*stream-context*))

      (close-uri s1)
      (close s2)
      (assert-eql 1 (hash-table-count xl-open-uri.core::*stream-context*))

      (xl-open-uri.core::do-cleanup #'(lambda (e) (setf callback-arg e)))
      (assert-eql 0 (hash-table-count xl-open-uri.core::*stream-context*))
      (assert-eql s2 callback-arg)
      ))
  )
