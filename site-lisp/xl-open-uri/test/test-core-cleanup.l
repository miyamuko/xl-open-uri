; -*- mode: lisp; package: xl-open-uri.test.core.cleanup; encoding: shift_jis -*-

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

(require "ansify")
(require "lisp-unit")

(require "xl-open-uri")
(require "xl-open-uri/test/helper")

(defpackage :xl-open-uri.test.core.cleanup
  (:use :lisp :editor
   :lisp-unit
   :xl-open-uri.core
   )
  )
(ansify::install :xl-open-uri.test.core.cleanup)

(in-package :xl-open-uri.test.core.cleanup)

(remove-all-tests :xl-open-uri.test.core.cleanup)

(define-test do-cleanup
  (let ((xl-open-uri.core::*stream-context* (make-hash-table))
        (callback-arg nil))
    (xl-open-uri.core::do-cleanup #'(lambda (e) (setf callback-arg e)))
    (assert-eql 0 (hash-table-count xl-open-uri.core::*stream-context*))
    (assert-eql nil callback-arg)
    )
  (let ((xl-open-uri.core::*stream-context* (make-hash-table))
        (callback-arg nil)
        (s (make-string-input-stream "")))
    (setf (gethash s xl-open-uri.core::*stream-context*) 123)
    (xl-open-uri.core::do-cleanup #'(lambda (e) (setf callback-arg e)))
    (assert-eql 1 (hash-table-count xl-open-uri.core::*stream-context*))
    (assert-eql nil callback-arg)

    (close s)
    (xl-open-uri.core::do-cleanup #'(lambda (e) (setf callback-arg e)))
    (assert-eql 0 (hash-table-count xl-open-uri.core::*stream-context*))
    (assert-eql s callback-arg)
    )
  )

(define-test start-cleanup-laster
  (let ((xl-open-uri.core::*stream-context* (make-hash-table))
        (xl-open-uri.core::*cleanup-waiting* nil)
        (callback-arg nil)
        (s1 (make-string-input-stream ""))
        (s2 (make-string-input-stream "")))
    (setf (gethash s1 xl-open-uri.core::*stream-context*) 123)
    (setf (gethash s2 xl-open-uri.core::*stream-context*) 123)

    (xl-open-uri.core::start-cleanup-later #'(lambda (e) (setf callback-arg e)) 0.3)

    (assert-eql 2 (hash-table-count xl-open-uri.core::*stream-context*))
    (assert-eql nil callback-arg)

    (close s1)
    (sit-for 0.1)
    (assert-eql 2 (hash-table-count xl-open-uri.core::*stream-context*))
    (assert-eql nil callback-arg)

    (sit-for 0.5)
    (assert-eql 1 (hash-table-count xl-open-uri.core::*stream-context*))
    (assert-eql s1 callback-arg)

    (close s2)
    (sit-for 0.5)
    (assert-eql 0 (hash-table-count xl-open-uri.core::*stream-context*))
    (assert-eql s2 callback-arg)
    )
  )
