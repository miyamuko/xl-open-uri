; -*- mode: lisp; package: xl-open-uri.protocols; encoding: shift_jis -*-

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
  (require "ansify")
  )

(eval-when (:compile-toplevel :load-toplevel :execute)
  (unless (find-package :xl-open-uri.protocols)
    (defpackage :xl-open-uri.protocols
      (:nicknames :open-uri.protocols)
      (:use
       :lisp
       :editor
       )
      ))
  (ansify::install :xl-open-uri.protocols))

(in-package :xl-open-uri.protocols)

(export '(find-protocol-handler
          add-protocol-handler
          remove-protocol-handler

          parse-media-type
          split-token
          ))

(defun find-protocol-handler (scheme)
  (open-uri.core::find-protocol-handler scheme))

(defun add-protocol-handler (scheme package)
  (open-uri.core::add-protocol-handler scheme package))

(defun remove-protocol-handler (scheme)
  (open-uri.core::remove-protocol-handler scheme))

(defun parse-media-type (media-type)
  (when (and media-type
             (string-matchp "\\`\\(.+?\\)\\(?:; *charset=\"?\\([^ ;\"]+\\)\"?\\)?\\'"
                            media-type))
    (let* ((content-type (normalize (match-string 1)))
           (charset (normalize (match-string 2)))
           (encoding (gethash charset *mime-charset-name-hash-table*)))
      (when (eq encoding *encoding-utf8*)
        (setf encoding *encoding-utf8n*))
      (values content-type charset encoding))))

(defun split-token (header &optional (separator #\,))
  (when header
    (mapcar #'normalize (split-string header separator))))

(defun normalize (s)
  (when s
    (string-downcase (string-trim " \r\t\f\n" s))))


(provide "xl-open-uri/protocols")

;;; End
