; -*- mode: lisp; package: xl-open-uri.test.core.types; encoding: shift_jis -*-

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

(defpackage :xl-open-uri.test.core.types
  (:use :lisp :editor
   :lisp-unit
   :xl-open-uri.core
   )
  )
(ansify::install :xl-open-uri.test.core.types)

(in-package :xl-open-uri.test.core.types)

(remove-all-tests :xl-open-uri.test.core.types)

(define-test open-stream
  (assert-eq nil
      (check-type (make-general-input-stream #'car) open-stream))
  (assert-eq nil
      (check-type (make-string-input-stream "") open-stream))
  (assert-eq nil
      (check-type (make-string-output-stream) open-stream))

  (assert-error 'type-error
      (check-type nil open-stream))
  (assert-error 'type-error
      (check-type "" open-stream))
  (assert-error 'type-error
      (check-type (let ((s (make-string-output-stream)))
                    (close s)
                    s)
                  open-stream))
  )

(define-test input-stream
  (assert-eq nil
      (check-type (make-general-input-stream #'car) input-stream))
  (assert-eq nil
      (check-type (make-string-input-stream "") input-stream))
  (assert-eq nil
      (check-type (let ((s (make-string-input-stream "")))
                    (close s)
                    s)
                  input-stream))

  (assert-error 'type-error
      (check-type (make-string-output-stream) input-stream))
  (assert-error 'type-error
      (check-type nil input-stream))
  (assert-error 'type-error
      (check-type "" input-stream))
  )

(define-test output-stream
  (assert-eq nil
      (check-type (make-general-output-stream #'car) output-stream))
  (assert-eq nil
      (check-type (make-string-output-stream) output-stream))
  (assert-eq nil
      (check-type (let ((s (make-string-output-stream)))
                    (close s)
                    s)
                  output-stream))

  (assert-error 'type-error
      (check-type (make-string-input-stream "") output-stream))
  (assert-error 'type-error
      (check-type nil output-stream))
  (assert-error 'type-error
      (check-type "" output-stream))
  )

(define-test open-input-stream
  (assert-eq nil
      (check-type (make-general-input-stream #'car) open-input-stream))
  (assert-eq nil
      (check-type (make-string-input-stream "") open-input-stream))

  (assert-error 'type-error
      (check-type (let ((s (make-string-input-stream "")))
                    (close s)
                    s)
                  open-input-stream))
  (assert-error 'type-error
      (check-type (make-string-output-stream) open-input-stream))

  (assert-error 'type-error
      (check-type nil open-input-stream))
  (assert-error 'type-error
      (check-type "" open-input-stream))
  )

(define-test open-output-stream
  (assert-eq nil
      (check-type (make-general-output-stream #'car) open-output-stream))
  (assert-eq nil
      (check-type (make-string-output-stream) open-output-stream))

  (assert-error 'type-error
      (check-type (let ((s (make-string-output-stream)))
                    (close s)
                    s)
                  open-output-stream))
  (assert-error 'type-error
      (check-type (make-string-input-stream "") open-output-stream))

  (assert-error 'type-error
      (check-type nil open-output-stream))
  (assert-error 'type-error
      (check-type "" open-output-stream))
  )
