; -*- mode: lisp; package: xl-open-uri.test.protocols.ftp; encoding: shift_jis -*-

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

(defpackage :xl-open-uri.test.protocols.ftp
  (:use :lisp :editor
   :lisp-unit
   :xl-open-uri
   :xl-open-uri.test.helper
   )
  )

(in-package :xl-open-uri.test.protocols.ftp)

(remove-all-tests :xl-open-uri.test.protocols.ftp)

(define-test open-uri-ftp
  (with-open-uri (f "ftp://ftp.gnu.org/gnu/clisp/clisp.png")
    (assert-equal "235b95875de984089bbcc0a246a4bf29"
        (si:md5 f))
    (assert-equal 3217611589
        (last-modified f)))
  (assert-error 'file-not-found
      (with-open-uri (f "ftp://ftp.gnu.org/gnu/clisp/clisp.png.not.found")
        ))
  )
