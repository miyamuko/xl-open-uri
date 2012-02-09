; -*- mode: lisp; package: xl-open-uri.http; encoding: shift_jis -*-

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
  (require "http-client")

  (require "xl-open-uri/package")
  (require "xl-open-uri/meta")

  (unless (find-package :xl-open-uri.http)
    (defpackage :xl-open-uri.http
      (:nicknames :xl-open-uri.https)
      (:use
       :lisp
       :editor
       :http-client
       )
      )))
(ansify::install :xl-open-uri)

(in-package :xl-open-uri.http)

(defun open-uri (uri &key
                     method headers query body encoding
                     auth proxy-auth
                     (proxy *http-proxy*)
                     no-redirect)
  (let (client stream chunks error)
    (labels ((completed-p ()
               (or (not client)
                   (not stream)
                   (http-response-completed-p client)))
             (reader ()
               (while (and (not chunks)
                           (not error)
                           (not (completed-p)))
                 (sleep-for 0.2))
               (when error
                 (error error))
               (when chunks
                 (prog1
                     (apply 'concat (nreverse chunks))
                   (setf chunks nil))))
             (closer (abort)
               (when (and client stream)
                 (unless (completed-p)
                   (http-request-abort client))
                 (xl-open-uri::unregister stream)
                 (setf chunks nil
                       client nil
                       stream nil)))
             (listener ()
               (or chunks
                   (not (completed-p)))))
      (setf client (http-request method uri body
                                 :query query
                                 :headers headers
                                 :encoding encoding
                                 :auth auth
                                 :proxy-auth proxy-auth
                                 :proxy proxy
                                 :no-redirect no-redirect
                                 :receiver (http-general-receiver
                                            #'(lambda (chunk)
                                                (unless (completed-p)
                                                  (push chunk chunks))
                                                stream))
                                 :onerror #'(lambda (err)
                                              (setf error err))
                                 ))
      (setf stream (make-general-input-stream #'reader #'closer #'listener))
      (xl-open-uri::register stream :xl-open-uri.http client)
      stream
      )))

(defun meta (client)
  (http-response-header-alist client))

(defun status (client)
  (values (http-response-status client)
          (http-response-status-text client)))

(defun base-uri (client)
  (http-request-uri client))

(defun content-encoding (client)
  (http-response-header client :content-encoding))

(defun content-type (client)
  (car (http-content-type client)))

(defun charset (client)
  (cadr (http-content-type client)))

(defun last-modified (client)
  (let ((date (http-response-header client :last-modified)))
    (when date
      (http-date-to-universal-time date))))


(defun http-content-type (client)
  (parse-content-type
   (http-response-header client :content-type)))

(defun parse-content-type (content-type)
  (when (and content-type
             (string-matchp "\\`\\(.+?\\)\\(?:; *charset=\"?\\([^ ;\"]+\\)\"?\\)?\\'"
                            content-type))
    (list (match-string 1)
          (match-string 2))))


(provide "xl-open-uri/http/http")

;;; End
