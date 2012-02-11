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
  (require "xl-winhttp")

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
  (direction nil :type keyword :read-only t)
  (if-exists nil :type keyword :read-only t)
  (encoding nil :type keyword :read-only t)
  (logger nil :type output-stream :read-only t)
  (path nil :type string :read-only t)
  (uri nil :type string)
  (last-modified nil :type integer)
  (listen-socket nil :type socket-stream)
  (ftp nil :type user::ftp)
  )

(defun open-uri (uri &key
                     (direction :input)
                     (if-exists :overwrite)
                     (encoding :binary)
                     (auth '("anonymous" nil))
                     (active-mode nil)
                     (logger nil)
                     )
  (check-type direction (member :input :output))
  (check-type encoding (member :binary :text))
  (check-type if-exists (member :error :append :overwrite :uniq))
  (multiple-value-bind (scheme user pass host port path query secure)
      (winhttp:crack-url uri)
    (let ((ctx (make-context :direction direction
                             :if-exists if-exists
                             :encoding encoding
                             :logger (make-logger-stream logger)
                             :path (concat path query)
                             :uri uri
                             ))
          (stream nil))
      (let ((*standard-output* (context-logger ctx))
            (user::*ftp-passive-mode* (not active-mode)))
        (handler-case
            (let ((ftp (user::ftp-connect host (ftp-port port))))
              (setf (context-ftp ctx) ftp)
              (socket-stream-set-oob-inline (user::ftp-stream ftp) t)
              (ftp-login ctx ftp auth user pass)
              (let ((exist-p (ftp-file-exist-p ctx ftp)))
                (values (ecase direction
                          (:input (ftp-open-input-stream ctx ftp :exist-p exist-p))
                          (:output (ftp-open-output-stream ctx ftp :exist-p exist-p)))
                        ctx)))
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
           (close-ftp stream ctx :abort nil)
         (close-ftp stream ctx :abort t)))
      (:output
       (close-ftp stream ctx :abort abort))
      )))

(defun base-uri (stream ctx)
  (context-uri ctx))

(defun last-modified (stream ctx)
  (context-last-modified ctx))


;;; ftp commands

(defun ftp-login (ctx ftp auth user pass)
  (cond (auth
         (user::ftp-login ftp (car auth) (cadr auth)))
        (user
         (user::ftp-login ftp user pass))
        ))

(defun ftp-open-input-stream (ctx ftp &key exist-p)
  (unless exist-p
    (error 'file-not-found
           :datum "指定されたファイルが見つかりません。"
           :pathname (context-uri ctx)))
  (ftp-set-meta-info ctx ftp)
  (ftp-open-data-stream ctx ftp :RETR))

(defun ftp-open-output-stream (ctx ftp &key exist-p)
  (let ((command (or (when exist-p
                       (case (context-if-exists ctx)
                         (:error (error 'file-exists :datum "ファイルがあります。"
                                        :pathname (context-uri ctx)))
                         (:append :APPE)
                         (:uniq :STOU)))
                     :STOR)))
    (case command
      (:STOU
       ;; STOU の場合、カレントディレクトリにユニークな名前でファイルを作成するので
       ;; まずディレクトリを変更しておく
       (user::ftp-cd ftp (dirname (context-path ctx)))
       (prog1
           (ftp-open-data-stream ctx ftp command)
         ;; その後、STOU で付けられたファイル名を URI に設定する
         (when (string-matchp "^FILE: \\(.+\\)$" (user::ftp-reply-text ftp))
           (rename-filename ctx (match-string 1)))))
      (t
       (ftp-open-data-stream ctx ftp command))
      )))

(defun ftp-open-data-stream (ctx ftp command)
  (ftp-change-mode ctx ftp)
  (let ((req (format nil "~A ~A" command (context-path ctx)))
        (listen-socket (user::ftp-init-data-stream ftp)))
    (setf (context-listen-socket ctx) listen-socket)
    (unless (= (user::ftp-command ftp req)
               user::*ftp-preliminary*)
      (ftp-error ctx ftp))
    (setf stream (user::ftp-connect-data-stream ftp listen-socket))
    (set-stream-encoding stream (context-encoding ctx))
    stream))

(defun ftp-set-meta-info (ctx ftp)
  (when (eq (context-direction ctx) :input)
    (setf (context-last-modified ctx)
          (or (user::ftp-mtime ftp (context-path ctx))
              (ftp-error ctx ftp)))))

(defun ftp-change-mode (ctx ftp)
  (let ((type (user::ftp-type ftp)))
    (ecase (context-encoding ctx)
      (:binary
       (unless (string= type user::*ftp-type-image*)
         (or (user::ftp-binary ftp)
             (ftp-error ctx ftp))))
      (:text
       (unless (string= type user::*ftp-type-ascii*)
         (or (user::ftp-ascii ftp)
             (ftp-error ctx ftp))))
      )))

(defun ftp-file-exist-p (ctx ftp)
  (member (context-path ctx)
          (user::ftp-nlist ftp (dirname (context-path ctx)))
          :test #'string=))


;;; internal

(defun ftp-error (ctx ftp)
  (error 'network-error
         :datum (format nil "FTP エラー: ~A ~A"
                        (user::ftp-reply-code ftp)
                        (user::ftp-reply-text ftp))
         :pathname (context-uri ctx)))

(defun close-ftp (stream ctx &key abort)
  (flet ((%close (s)
           (when (and s (open-stream-p s))
             (close s :abort abort))))
    (when-let (ftp (context-ftp ctx))
      (%close stream)
      (%close (context-listen-socket ctx))
      (when stream
        (cond (abort
               ;; stream を指定すると ftp-abort 内でデータを最後まで読みきろうとして(?)
               ;; ブロックするので、事前に close して nil を指定する
               (user::ftp-abort ftp nil))
              (t
               ;; 226 Transfer complete を読んであげる
               (user::ftp-get-reply ftp)
               ;; QUIT を送ってあげる
               (user::ftp-quit ftp))
              ))
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

(defun make-ftp-command (ctx &key if-exists)
  (format nil "~A ~A"
          (ecase (context-direction ctx)
            (:input "RETR")
            (:output
             (ecase if-exists
               (:overwrite "STOR")
               (:append "APPE")
               (:uniq "STOU")
               )))
          (context-path ctx)))

(defun rename-filename (ctx new-filename)
  (setf (context-uri ctx)
        (concat (dirname (context-uri ctx)) new-filename)))

(defun dirname (path)
  (append-trail-slash
   (nth-value 0 (split-path path))))

(defun split-path (path)
  (when (string-matchp "[^/]+$" path)
    (values (substring path 0 (match-beginning 0))
            (match-string 0))))


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
