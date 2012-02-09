; -*- mode: lisp; package: xl-open-uri; encoding: shift_jis -*-

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
  (require "xl-open-uri/package")
  )

(in-package :xl-open-uri)

(defparameter *stream-object*
  (make-hash-table))

(defun register (stream package object)
  (setf (gethash stream *stream-object*)
        (list package object)))

(defun unregister (stream)
  (remhash stream *stream-object*))

(defun fetch (stream)
  (values-list
   (gethash stream *stream-object*)))


(defun get-meta-info (stream type)
  (multiple-value-bind (package object)
      (fetch stream)
    (when (and package object)
      (let ((fn (intern (string type) package)))
        (when (fboundp fn)
          (funcall fn object))))))

(defmacro define-meta (type)
  `(progn
     (defun ,type (stream)
       (get-meta-info stream ',type))
     (export ',type)))

(define-meta meta)
(define-meta status)
(define-meta base-uri)
(define-meta content-type)
(define-meta content-encoding)
(define-meta charset)
(define-meta last-modified)


(provide "xl-open-uri/meta")

;;; End
