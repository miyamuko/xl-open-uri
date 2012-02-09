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

(export '(open
          ))

(defun open (uri &rest args)
  (check-type uri string)
  (cond ((string-match "\\`\\([a-z]+\\)://" uri)
         (cond ((string= (match-string 1) "file")
                (apply 'lisp:open (substring uri (match-end 0)) args))
               (t
                (apply 'open-uri (match-string 1) uri args))))
        (t
         (apply 'lisp:open uri args))
        ))

(defun open-uri (scheme uri &rest args)
  (let ((module (format nil "xl-open-uri/~A/~A" scheme scheme))
        (pkgname (format nil "xl-open-uri.~A" scheme)))
    (unless (find-load-path module)
      (error "~A not supported: ~A" scheme uri))
    (require module)
    (let ((pkg (find-package pkgname)))
      (unless pkg
        (error "Package not found: ~A" pkgname))
      (let ((fn (intern "open-uri" pkg)))
        (unless (fboundp fn)
          (error "Function not defined: ~A:open-uri" pkgname))
        (apply fn uri args)))))


(provide "xl-open-uri/api")


;;; End
