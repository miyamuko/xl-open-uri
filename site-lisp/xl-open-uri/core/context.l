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
  (require "xl-open-uri/core/types")
  )

(in-package :xl-open-uri.core)

(export '(register-context
          unregister-context
          dispatch-generic-function
          define-context-accessor
          ))

(defvar *stream-context* (make-hash-table))

(defun register-context (stream package context)
  (setf (gethash stream *stream-context*)
        (list package context)))

(defun unregister-context (stream)
  (remhash stream *stream-context*))

(defun get-context (stream)
  (values-list
   (gethash stream *stream-context*)))


(defun dispatch-generic-function (stream sym &rest options)
  (multiple-value-bind (package context)
      (get-context stream)
    (when (and package context)
      (let ((fn (intern (string sym) package)))
        (when (fboundp fn)
          (apply fn stream context options))))))

(defmacro define-context-accessor (sym)
  `(progn
     (defun ,sym (stream)
       (check-type stream open-stream)
       (dispatch-generic-function stream ',sym))
     (export ',sym)))


(provide "xl-open-uri/core/context")

;;; End
