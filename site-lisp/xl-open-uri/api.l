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
  (require "xl-open-uri/meta")
  )

(in-package :xl-open-uri)

(export '(open-uri
          with-open-uri
          ))

(defmacro with-open-uri ((stream uri &rest options) &body body)
  `(with-open-stream (,stream (open-uri ,uri ,@options))
     ,@body))
(setf (get 'with-open-uri 'ed:lisp-indent-hook) 1)

(defun open-uri (uri &rest options)
  (check-type uri string)
  (cond ((string-match "\\`\\([a-z]+\\)://" uri)
         (cond ((string= (match-string 1) "file")
                (apply 'lisp:open (substring uri (match-end 0)) options))
               (t
                (apply 'open-uri-internal (match-string 1) uri options))))
        (t
         (apply 'lisp:open uri options))
        ))

(defun open-uri-internal (scheme uri &rest options)
  (let ((fn (find-open-function scheme uri)))
    (multiple-value-bind (reader closer listener meta)
        (apply fn uri options)
      (let (stream)
        (setf stream (make-general-input-stream reader
                                                #'(lambda (abort)
                                                    (unwind-protect
                                                        (funcall closer abort)
                                                      (unregister-meta stream)))
                                                listener))
        (register-meta stream (symbol-package fn) meta)
        stream))))

(defun find-open-function (scheme uri)
  (let* ((module (format nil "xl-open-uri/provider/~A" scheme))
         (pkgname (substitute #\. #\/ module)))
    (unless (find-load-path module)
      (error "~A not supported: ~A" scheme uri))
    (require module)
    (let ((pkg (find-package pkgname)))
      (unless pkg
        (error "Package not found: ~A" pkgname))
      (let ((fn (intern "open-uri" pkg)))
        (unless (fboundp fn)
          (error "Function not defined: ~A:open-uri" pkgname))
        fn))))


(provide "xl-open-uri/api")

;;; End
