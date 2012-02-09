; -*- mode: lisp; package: xl-open-uri.extensions; encoding: shift_jis -*-

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
  (require "xl-open-uri/api")

  (unless (find-package :xl-open-uri.extensions)
    (defpackage :xl-open-uri.extensions
      (:nicknames :open-uri.ext :xl-open-uri.ext :open-uri.extensions)
      (:use
       :lisp
       :xl-open-uri.api
       )
      )))

(in-package :xl-open-uri.extensions)

(shadow '(open
          close
          with-open-stream
          with-open-file
          ))

(export '(open
          close
          with-open-stream
          with-open-file
          install
          uninstall
          ))

(defun open (uri &rest options)
  (apply 'open-uri uri options))

(defun close (stream &key abort)
  (close-uri stream :abort abort))

(defmacro with-open-stream ((var stream) &body body)
  (multiple-value-bind (decl body)
      (lisp::find-declaration body)
    `(let ((,var ,stream))
       ,@decl
       (unwind-protect
           (multiple-value-prog1
            (progn ,@body)
            (and ,var (close-uri ,var)))
         (and ,var (close-uri ,var :abort t))))))
(setf (get 'with-open-stream 'ed:lisp-indent-hook) 1)

(defmacro with-open-file ((stream uri &rest options) &body body)
  `(with-open-stream (,stream (open ,uri ,@options))
     ,@body))
(setf (get 'with-open-file 'ed:lisp-indent-hook) 1)


(defun install (&optional (package *package*))
  (import-extensions :import-from :xl-open-uri.extensions
                     :package package))

(defun uninstall (&optional (package *package*))
  (import-extensions :import-from :lisp
                     :package package))

(defun import-extensions (&key import-from package)
  (dolist (sym (package-shadowing-symbols :open-uri.ext))
    (shadowing-import (intern (string sym) import-from) package)))


(provide "xl-open-uri/extensions")

;;; End
