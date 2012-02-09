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
  (require "xl-open-uri/core/context")
  (require "xl-open-uri/core/cleanup")
  )

(in-package :xl-open-uri.core)

(export '(open-uri-internal
          close-uri-internal
          ))

(defvar *protocol-handler-alist* nil)


(defun open-uri-internal (uri &rest options)
  (check-type uri string)
  (cond ((string-match "\\`\\([a-z]+\\):" uri)
         (let ((scheme (coerce-scheme-keyword (match-string 1))))
           (case scheme
             (:file
              (apply 'lisp:open (substring uri (match-end 0)) options))
             (t
              (apply 'dispatch-open-uri scheme uri options)))))
        (t
         (apply 'lisp:open uri options))
        ))

(defun dispatch-open-uri (scheme uri &rest options)
  (check-type scheme keyword)
  (let* ((pkg (find-protocol-handler scheme))
         (fn (find-open-function pkg)))
    (multiple-value-bind (stream context)
        (apply fn uri options)
      (register-context stream pkg context)
      (start-cleanup-later #'close-uri-internal)
      stream)))


(defun close-uri-internal (stream &key abort)
  (unwind-protect
      (progn
        (when (open-stream-p stream)
          (close stream))
        (dispatch-generic-function stream 'close-uri :abort abort))
    (unregister-context stream)))


(defun find-protocol-handler (scheme)
  (setf scheme (coerce-scheme-keyword scheme))
  (or (cdr (assoc scheme *protocol-handler-alist*))
      (load-default-protocol-handler scheme)))

(defun load-default-protocol-handler (scheme)
  (let* ((module (format nil "xl-open-uri/protocols/~A" scheme))
         (pkgname (substitute #\. #\/ module)))
    (unless (find-load-path module)
      (error "~A not supported: ~A" scheme))
    (require module)
    (package-name (lisp::coerce-to-package pkgname))))


(defun add-protocol-handler (scheme package)
  (setf scheme (coerce-scheme-keyword scheme))
  (setf package (coerce-package-keyword package))
  (if-let (exist (find scheme *protocol-handler-alist*
                       :key #'car))
      (unless (eql (cdr exist) package)
        (warn "Override protocol handler: ~A => ~A" (cdr exist) package)
        (setf (cdr exist) package))
    (push (cons scheme package) *protocol-handler-alist*))
  *protocol-handler-alist*)

(defun remove-protocol-handler (scheme)
  (setf scheme (coerce-scheme-keyword scheme))
  (setf *protocol-handler-alist*
        (delete scheme *protocol-handler-alist*
                :key #'car)))


(defun find-open-function (package)
  (let ((pkg (lisp::coerce-to-package package)))
    (let ((fn (intern "open-uri" pkg)))
      (unless (fboundp fn)
        (error 'undefined-function :name fn))
      fn)))


(defun coerce-scheme-keyword (scheme)
  (check-type scheme string-designator)
  (make-keyword (string scheme)))

(defun coerce-package-keyword (package)
  (check-type package (or package string-designator))
  (make-keyword (package-name (lisp::coerce-to-package package))))


(provide "xl-open-uri/core/handler")

;;; End
