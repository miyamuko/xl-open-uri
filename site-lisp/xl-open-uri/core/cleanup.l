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
  )

(in-package :xl-open-uri.core)

;; ## メモ
;;
;; open-uri:close-uri を使わずに lisp:close などでストリームを閉じた場合、
;; *stream-context* からメタ情報を削除するタイミングがない。
;;
;; general-{input|output}-stream なら close のタイミングで任意の処理を実行できるが、
;; それ以外 (two-way-stream や通常の network-stream など) の場合は無理。
;;
;; 基本的に with-open-uri マクロを使ってもらうとして、うっかり忘れた場合に
;; 備えて timer で監視し、close されたストリームがあったら close-uri を
;; 自動的に呼び出すようにする。
;;

(defvar *cleanup-waiting* nil)
(defvar *cleanup-interval* 5)

(defun start-cleanup-later (callback &optional (interval *cleanup-interval*))
  (unless *cleanup-waiting*
    (setf *cleanup-waiting* t)
    (start-timer interval (curry #'on-cleanup callback) t)))

(defun on-cleanup (callback)
  (setf *cleanup-waiting* nil)
  (do-cleanup callback)
  (when (< 0 (hash-table-count *stream-context*))
    (start-cleanup-later callback)))

(defun do-cleanup (callback)
  (let (garbages)
    (maphash #'(lambda (stream _)
                 (unless (open-stream-p stream)
                   (push stream garbages)))
             *stream-context*)
    (dolist (s garbages)
      (ignore-errors
       (funcall callback s))
      (unregister-context s))))


(provide "xl-open-uri/core/cleanup")

;;; End
