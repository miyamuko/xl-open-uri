; -*- mode: lisp; package: xl-open-uri.protocols.http; encoding: shift_jis -*-

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
  (require "xl-alexandria")
  (require "xl-open-uri/protocols")

  (unless (find-package :xl-open-uri.protocols.http)
    (defpackage :xl-open-uri.protocols.http
      (:nicknames :xl-open-uri.protocols.https)
      (:use
       :lisp
       :editor
       :alexandria
       :http-client
       )
      (:shadowing-import-from :lisp
       :copy-file
       :featurep
       )
      (:import-from :xl-open-uri.protocols
       :add-protocol-handler
       :parse-media-type
       :split-token
       )
      )))
(ansify::install :xl-open-uri.protocols.http)

(in-package :xl-open-uri.protocols.http)

(add-protocol-handler :http :xl-open-uri.protocols.http)
(add-protocol-handler :https :xl-open-uri.protocols.https)

(defvar *default-content-type* "application/octet-stream")
(defvar *default-text-charset* "iso-8859-1")
(defvar *read-wait-interval* 0.2)

(defun open-uri (uri &key
                     method headers query body
                     encoding (response-encoding t)
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
                 (sit-for *read-wait-interval*))
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
                                                  (push chunk chunks)))
                                            :line t :encoding response-encoding)
                                 :onerror #'(lambda (err)
                                              (setf error err))
                                 ))
      (values (make-general-input-stream #'reader #'closer #'listener)
              client)
      )))


(defun meta (stream client &optional key)
  (if key
      (http-response-header client key)
    (http-response-header-alist client)))

(defun status (stream client)
  (values (http-response-status client)
          (http-response-status-text client)))

(defun base-uri (stream client)
  (http-request-uri client))

(defun content-encoding (stream client)
  (split-token (http-response-header client :content-encoding)))

(defun content-type (stream client)
  (nth-value 0 (http-media-type client)))

(defun charset (stream client)
  (multiple-value-bind (type charset encoding)
      (http-media-type client)
    (or charset
        (when (and type (string-match "^text/" type))
          *default-text-charset*))))

(defun last-modified (stream client)
  (when-let (date (http-response-header client :last-modified))
    (http-date-to-universal-time date)))


(defun http-media-type (client)
  (parse-media-type
   (http-response-header client :content-type)))


(provide "xl-open-uri/protocols/http")

;;; End
