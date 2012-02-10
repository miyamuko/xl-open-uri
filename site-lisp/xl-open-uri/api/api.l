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
  (require "xl-open-uri/api/package")
  )

(in-package :xl-open-uri)

(export '(with-open-uri
          open-uri
          close-uri
          read-all
          read-block
          read-partial
          meta
          ))

(defmacro with-open-uri ((var uri &rest options) &body body)
  (multiple-value-bind (decl body)
      (lisp::find-declaration body)
    `(let ((,var (open-uri ,uri ,@options)))
       ,@decl
       (unwind-protect
           (multiple-value-prog1
            (progn ,@body)
            (and ,var (close-uri ,var)))
         (and ,var (close-uri ,var :abort t))))))
(setf (get 'with-open-uri 'ed:lisp-indent-hook) 1)

(defun open-uri (uri &rest options)
  (apply 'open-uri.core:open-uri-internal uri options))

(defun close-uri (stream &key abort)
  (funcall 'open-uri.core:close-uri-internal stream :abort abort))


(defun read-all (stream &optional encoding (eof-error-p t) eof-value)
  (check-type stream open-input-stream)
  (cond ((eq eof-value (peek-char nil stream eof-error-p eof-value))
         eof-value)
        (encoding
         (convert-encoding-to-internal encoding stream))
        (t
         (with-output-to-string (os)
           (copy-stream stream os)))))

(defun read-block (stream max-length &optional (eof-error-p t) eof-value buffer)
  (check-type stream open-input-stream)
  (when (<= max-length 0)
    (return-from read-block ""))
  (unless buffer
    (setf buffer (make-vector max-length :element-type 'character :fill-pointer 0)))
  (read-into buffer stream eof-error-p eof-value))

(defun read-partial (stream max-length &optional (eof-error-p t) eof-value)
  (check-type stream open-input-stream)
  (when (<= max-length 0)
    (return-from read-partial ""))
  (cond ((eq eof-value (peek-char nil stream eof-error-p eof-value))
         eof-value)
        (t
         (with-output-to-string (out)
           (do ((c (read-char stream eof-error-p eof-value)
                   (read-char-no-hang stream nil nil))
                (n 1 (1+ n)))
               ((or (eq c nil)
                    (eq c eof-value)))
             (write-char c out)
             (when (<= max-length n)
               (return))
             )))))


(defun meta (stream &optional key)
  (check-type stream open-stream)
  (dispatch-generic-function stream 'meta key))

(define-context-accessor status)
(define-context-accessor base-uri)
(define-context-accessor content-type)
(define-context-accessor content-encoding)
(define-context-accessor charset)
(define-context-accessor last-modified)


(provide "xl-open-uri/api/api")

;;; End
