; -*- mode: lisp; package: xl-open-uri.core; encoding: shift_jis -*-

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

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "xl-open-uri/core/package")
  )

(in-package :xl-open-uri.core)

(export '(open-stream
          input-stream
          output-stream
          open-input-stream
          open-output-stream
          ))

(deftype open-stream ()
  `(and stream
        (satisfies open-stream-p)))

(deftype input-stream ()
  `(and stream
        (satisfies input-stream-p)))

(deftype output-stream ()
  `(and stream
        (satisfies output-stream-p)))

(deftype open-input-stream ()
  `(and open-stream
        input-stream))

(deftype open-output-stream ()
  `(and open-stream
        output-stream))


(provide "xl-open-uri/core/types")

;;; End
