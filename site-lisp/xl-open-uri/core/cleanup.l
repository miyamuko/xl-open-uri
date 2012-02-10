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

;; ## ����
;;
;; open-uri:close-uri ���g�킸�� lisp:close �ȂǂŃX�g���[��������ꍇ�A
;; *stream-context* ���烁�^�����폜����^�C�~���O���Ȃ��B
;;
;; general-{input|output}-stream �Ȃ� close �̃^�C�~���O�ŔC�ӂ̏��������s�ł��邪�A
;; ����ȊO (two-way-stream ��ʏ�� network-stream �Ȃ�) �̏ꍇ�͖����B
;;
;; ��{�I�� with-open-uri �}�N�����g���Ă��炤�Ƃ��āA��������Y�ꂽ�ꍇ��
;; ������ timer �ŊĎ����Aclose ���ꂽ�X�g���[������������ close-uri ��
;; �����I�ɌĂяo���悤�ɂ���B
;;

(defvar *cleanup-waiting* nil)
(defvar *cleanup-interval* 5)

(defun start-cleanup-later (callback &optional (interval *cleanup-interval*))
  (unless *cleanup-waiting*
    (setf *cleanup-waiting* t)
    (start-timer interval #'(lambda ()
                              (setf *cleanup-waiting* nil)
                              (do-cleanup callback)
                              (when (< 0 (hash-table-count *stream-context*))
                                (start-cleanup-later callback interval)))
                 t)))

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