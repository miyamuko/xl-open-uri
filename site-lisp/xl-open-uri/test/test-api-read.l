; -*- mode: lisp; package: xl-open-uri.test.api.read; encoding: shift_jis -*-

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

;;
;; https://github.com/miyamuko/node-test-httpd ÇóòópÇµÇΩÉeÉXÉgÅB
;;

;;; Code:

(require "lisp-unit")

(require "json")
(require "http-client")
(require "xl-open-uri")
(require "xl-open-uri/test/helper")

(defpackage :xl-open-uri.test.api.read
  (:use :lisp :editor
   :lisp-unit
   :json
   :http-client
   :xl-open-uri
   :xl-open-uri.test.helper
   )
  )

(in-package :xl-open-uri.test.api.read)

(remove-all-tests :xl-open-uri.test.api.read)

(define-test read-all
  (with-open-uri (s "http://localhost:3000/chunked?n=3&interval=100")
    (assert-equal "chunk data 3\nchunk data 2\nchunk data 1\nchunk data 0\n"
        (read-all s))
    (assert-error 'end-of-file
        (read-all s))
    (assert-eq :eof
        (read-all s nil nil :eof))
    )
  (with-open-file (s "test-file-lf-utf8.bin" :direction :input)
    (assert-equal (utf8 "xyzzy\nXYZZY\nÇòÇôÇöÇöÇô\nèLÇ¢ñÍ")
        (read-all s))
    )
  (with-open-file (s "test-file-lf-utf8.bin" :direction :input :encoding :binary)
    (assert-equal (bin (utf8 "xyzzy\nXYZZY\nÇòÇôÇöÇöÇô\nèLÇ¢ñÍ"))
        (read-all s *encoding-binary*))
    )
  (with-open-file (s "test-file-lf-utf8.bin" :direction :input)
    (assert-equal "xyzzy\nXYZZY\nÇòÇôÇöÇöÇô\nèLÇ¢ñÍ"
        (read-all s *encoding-utf8n*))
    )
  (with-open-file (s "test-file-lf-utf8.bin" :direction :input :encoding :binary)
    (assert-equal "xyzzy\nXYZZY\nÇòÇôÇöÇöÇô\nèLÇ¢ñÍ"
        (read-all s *encoding-utf8n*))
    )
  (with-input-from-string (s "")
    (assert-equal :eof (read-all s nil nil :eof)))
  )

(define-test read-block
  (with-open-uri (s "http://localhost:3000/chunked?n=3&interval=100")
    (assert-equal "chunk data 3\nchunk data 2\nchunk data 1\nchunk data 0\n"
        (read-block s (* 4 13)))
    (assert-error 'end-of-file
        (read-block s (* 4 13)))
    (assert-eq :eof
        (read-block s (* 4 13) nil :eof))
    )
  (with-open-file (s "test-file-lf-utf8.bin" :direction :input :encoding :binary)
    (let ((buffer (make-vector 4096 :element-type 'character :fill-pointer 0)))
      (let ((r (read-block s 4096 nil nil buffer)))
        (assert-eq r buffer)
        (assert-equal (bin (utf8 "xyzzy\nXYZZY\nÇòÇôÇöÇöÇô\nèLÇ¢ñÍ"))
            r)))
    )
  (with-input-from-string (s "")
    (assert-equal "" (read-block s 0))
    (assert-equal :eof (read-block s 1 nil :eof)))
  )

(define-test read-partial
  (with-open-uri (s "http://localhost:3000/chunked?n=3&interval=500")
    (assert-equal "chunk data 3\n"
        (read-partial s (* 4 13)))
    (assert-equal "chunk data 2\n"
        (read-partial s (* 4 13)))
    (assert-equal "chunk data 1\n"
        (read-partial s (* 4 13)))
    (assert-equal "chunk data 0\n"
        (read-partial s (* 4 13)))
    (assert-error 'end-of-file
        (read-partial s (* 4 13)))
    (assert-eq :eof
        (read-partial s (* 4 13) nil :eof))
    )
  (with-open-file (s "test-file-lf-utf8.bin" :direction :input :encoding :binary)
    (let ((r (read-partial s 4096 nil nil)))
      (assert-equal (bin (utf8 "xyzzy\nXYZZY\nÇòÇôÇöÇöÇô\nèLÇ¢ñÍ"))
          r)))
  (with-input-from-string (s "")
    (assert-equal "" (read-partial s 0))
    (assert-equal :eof (read-partial s 1 nil :eof)))
  )
