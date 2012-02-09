; -*- mode: lisp; package: xl-open-uri.provider.http; encoding: shift_jis -*-

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

  (unless (find-package :xl-open-uri.provider.http)
    (defpackage :xl-open-uri.provider.http
      (:nicknames :xl-open-uri.provider.https)
      (:use
       :lisp
       :editor
       :http-client
       )
      )))
(ansify::install :xl-open-uri.provider.http)

(in-package :xl-open-uri.provider.http)

(defvar *default-content-type* "application/octet-stream")
(defvar *default-text-charset* "iso-8859-1")
(defvar *read-wait-interval* 0.2)

(defun open-uri (uri &key
                     method headers query body encoding
                     auth proxy-auth
                     (proxy *http-proxy*)
                     no-redirect)
  (let (client chunks error)
    (labels ((completed-p ()
               (or (not client)
                   (http-response-completed-p client)))
             (reader ()
               (while (and (not chunks)
                           (not error)
                           (not (completed-p)))
                 (http-response-wait client :timeout *read-wait-interval* :abort-on-quit nil))
               (when error
                 (error error))
               (when chunks
                 (prog1
                     (apply 'concat (nreverse chunks))
                   (setf chunks nil))))
             (closer (abort)
               (when client
                 (unless (completed-p)
                   (http-request-abort client))
                 (setf chunks nil
                       client nil)))
             (listener ()
               (not (null chunks))))
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
                                                (when chunk
                                                  (push chunk chunks))))
                                 :onerror #'(lambda (err)
                                              (setf error err))
                                 ))
      (values #'reader #'closer #'listener client)
      )))

(defun meta (client &optional key)
  (if key
      (http-response-header client key)
    (http-response-header-alist client)))

(defun status (client)
  (values (http-response-status client)
          (http-response-status-text client)))

(defun base-uri (client)
  (http-request-uri client))

(defun content-encoding (client)
  (let ((v (http-response-header client :content-encoding)))
    (when v
      (mapcar #'normalize (split-string v #\,)))))

(defun content-type (client)
  (nth-value 0 (http-content-type client)))

(defun charset (client)
  (multiple-value-bind (type charset)
      (http-content-type client)
    (or charset
        (when (and type (string-match "^text/" type))
          *default-text-charset*))))

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
    (let ((type (match-string 1))
          (charset (match-string 2)))
      (values (normalize type)
              (normalize charset)))))

(defun normalize (s)
  (when s
    (string-downcase (http-client.base::strip s))))


(provide "xl-open-uri/provider/http")

;;; End
