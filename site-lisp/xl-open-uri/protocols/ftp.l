; -*- mode: lisp; package: xl-open-uri.protocols.ftp; encoding: shift_jis -*-

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
  (require "wip/ftp") ;; user package

  (require "ansify")
  (require "xl-alexandria")
  (require "xl-open-uri/core")
  (require "xl-open-uri/protocols")

  (unless (find-package :xl-open-uri.protocols.ftp)
    (defpackage :xl-open-uri.protocols.ftp
      (:use
       :lisp
       :editor
       :alexandria
       )
      (:shadowing-import-from :lisp
       :copy-file
       :featurep
       )
      (:import-from :xl-open-uri.protocols
       :add-protocol-handler
       )
      (:import-from :xl-open-uri.core
       :open-output-stream
       )
      )))
(ansify::install :xl-open-uri.protocols.ftp)

(in-package :xl-open-uri.protocols.ftp)

(add-protocol-handler :ftp :xl-open-uri.protocols.ftp)

(defstruct context
  (direction nil :type (member :input :output) :read-only t)
  (uri nil :type string :read-only t)
  (path nil :type string :read-only t)
  (last-modified nil :type integer)
  (listen-socket nil :type socket-stream)
  (ftp nil :type user::ftp)
  (logger nil :type output-stream)
  )

(defun open-uri (uri &key
                     (direction :input)
                     (encoding :binary)
                     (auth '("anonymous" nil))
                     (active-mode nil)
                     (logger nil)
                     )
  (check-type encoding (member :binary :text))
  (multiple-value-bind (scheme user pass host port path query secure)
      (winhttp:crack-url uri)
    (let ((ctx (make-context :direction direction
                             :uri uri
                             :path (concat path query)
                             :logger (make-logger-stream logger)
                             ))
          (stream nil))
      (let ((*standard-output* (context-logger ctx))
            (user::*ftp-passive-mode* (not active-mode)))
        (handler-case
            (let ((ftp (user::ftp-connect host (ftp-port port))))
              (setf (context-ftp ctx) ftp)
              (socket-stream-set-oob-inline (user::ftp-stream ftp) t)
              ;; login
              (cond (auth (user::ftp-login ftp (car auth) (cadr auth)))
                    (user (user::ftp-login ftp user pass)))
              ;; get meta info
              (when (eq direction :input)
                (setf (context-last-modified ctx)
                      (user::ftp-mtime ftp (context-path ctx))))
              ;; change to transfer mode
              (let ((type (user::ftp-type ftp)))
                (ecase encoding
                  (:binary
                   (unless (string= type user::*ftp-type-image*)
                     (user::ftp-binary ftp)))
                  (:text
                   (unless (string= type user::*ftp-type-ascii*)
                     (user::ftp-ascii ftp)))))
              ;; open data stream
              (let ((command (make-ftp-command ctx))
                    (listen-socket (user::ftp-init-data-stream ftp)))
                (setf (context-listen-socket ctx) listen-socket)
                (unless (= (user::ftp-command ftp command)
                           user::*ftp-preliminary*)
                  (error "FTP command failed: ~A" command))
                (setf stream (user::ftp-connect-data-stream ftp listen-socket))
                (set-stream-encoding stream :binary)
                (values stream ctx)))
          (error (c)
            (close-uri stream ctx :abort t)
            (error c))
          (quit (c)
            (close-uri stream ctx :abort t)
            (error c))
          )))))

(defun close-uri (stream ctx &key abort)
  (let ((*standard-output* (context-logger ctx)))
    (ecase (context-direction ctx)
      (:input
       (if (eofp stream)
           (close-ftp stream ctx :abort abort)
         (close-ftp stream ctx :abort t)))
      (:output
       (close-ftp stream ctx :abort abort))
      )))

(defun base-uri (stream ctx)
  (context-uri ctx))

(defun last-modified (stream ctx)
  (context-last-modified ctx))


;;; internal

(defun close-ftp (stream ctx &key abort)
  (flet ((%close (s)
           (when (and s (open-stream-p s))
             (close s :abort abort))))
    (when-let (ftp (context-ftp ctx))
      (%close stream)
      (%close (context-listen-socket ctx))
      (cond (abort
             ;; stream を指定すると ftp-abort 内でデータを最後まで読みきろうとして(?)
             ;; ブロックするので、事前に close して nil を指定する
             (user::ftp-abort ftp nil))
            (t
             ;; 226 Transfer complete を読んであげる
             (user::ftp-get-reply ftp)
             ;; QUIT を送ってあげる
             (user::ftp-quit ftp))
            )
      (%close (user::ftp-stream ftp))
      )))

(defun eofp (stream)
  (and stream
       (streamp stream)
       (open-stream-p stream)
       (input-stream-p stream)
       (eq :eof (peek-char nil stream nil :eof))
       ))

(defun context-ftp-stream (ctx)
  (when-let (ftp (context-ftp ctx))
    (user::ftp-stream ftp)))

(defun ftp-port (port)
  (if (and port (< 0 port))
      port
    "ftp"))

(defun make-ftp-command (ctx)
  (format nil "~A ~A"
          (ecase (context-direction ctx)
            (:input "RETR")
            (:output "STOR"))
          (context-path ctx)))

(defun make-logger-stream (logger)
  (check-type logger (or (member t nil) open-output-stream))
  (etypecase logger
    (symbol
     (if logger
         *standard-output*
       (make-null-output-stream)))
    (open-output-stream
     logger)))

(defun make-null-output-stream ()
  (make-general-output-stream #'(lambda (_))))


(provide "xl-open-uri/protocols/ftp")

;;; End
