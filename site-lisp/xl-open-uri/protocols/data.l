; -*- mode: lisp; package: xl-open-uri.protocols.data; encoding: shift_jis -*-

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
  (require "xl-open-uri/protocols")

  (unless (find-package :xl-open-uri.protocols.data)
    (defpackage :xl-open-uri.protocols.data
      (:use
       :lisp
       :editor
       )
      (:import-from :xl-open-uri.protocols
       :add-protocol-handler
       :parse-media-type
       )
      )))
(ansify::install :xl-open-uri.protocols.data)

(in-package :xl-open-uri.protocols.data)

(add-protocol-handler :data :xl-open-uri.protocols.data)

;; Syntax:
;;   dataurl    := "data:" [ mediatype ] [ ";base64" ] "," data
;;   mediatype  := [ type "/" subtype ] *( ";" parameter )
;;   data       := *urlchar
;;   parameter  := attribute "=" value
;;
;; Examples:
;;   data:text/plain;charset=iso-8859-7,%be%fg%be
;;   data:,A%20brief%20note
;;   data:image/gif;base64,R0lGODdhMAAwAPAAAAAAAP
;;
;; http://tools.ietf.org/html/rfc2397
(defun open-uri (uri)
  (unless (string-match "data:\\(.*?\\)\\(;base64\\)?," uri)
    (error "Invalid data URL: ~A" uri))
  (let ((media-type (match-string 1))
        (base64 (match-string 2))
        (data (substring uri (match-end 0))))
    (multiple-value-bind (content-type charset encoding)
        (parse-media-type media-type)
      (values (make-string-input-stream
               (decode-data data :base64 base64 :encoding encoding))
              (list uri content-type charset)))))

(defun decode-data (data &key base64 encoding)
  (let ((binstr (if base64
                    (si:base64-decode data)
                  (si:www-url-decode data))))
    (if encoding
        (convert-encoding-to-internal encoding binstr)
      binstr)))

(defun base-uri (stream meta)
  (nth 0 meta))

(defun content-type (stream meta)
  (nth 1 meta))

(defun charset (stream meta)
  (nth 2 meta))


(provide "xl-open-uri/protocols/data")

;;; End
