; -*- mode: lisp; package: xl-open-uri.test.protocols.data; encoding: shift_jis -*-

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

(require "lisp-unit")

(require "xl-open-uri")
(require "xl-open-uri/test/helper")

(defpackage :xl-open-uri.test.protocols.data
  (:use :lisp :editor
   :lisp-unit
   :xl-open-uri
   :xl-open-uri.test.helper
   )
  )

(in-package :xl-open-uri.test.protocols.data)

(remove-all-tests :xl-open-uri.test.protocols.data)

(define-test open-uri/url-encode
  (with-open-uri (s "data:,A%20brief%20note")
    (assert-equal "A brief note" (read-all s))
    (assert-equal "data:,A%20brief%20note" (base-uri s))
    (assert-equal nil (content-type s))
    (assert-equal nil (charset s))
    )
  (with-open-uri (s (concat "data:text/plain;charset=utf-8," (si:www-url-encode (utf8 "‚ ‚¢‚¤"))))
    (assert-equal "‚ ‚¢‚¤" (read-all s))
    (assert-equal "text/plain" (content-type s))
    (assert-equal "utf-8" (charset s))
    )
  (with-open-uri (s (concat "data:text/plain," (si:www-url-encode (utf8 "‚ ‚¢‚¤"))))
    (assert-equal "‚ ‚¢‚¤" (read-all s *encoding-utf8n*))
    (assert-equal "text/plain" (content-type s))
    (assert-equal nil (charset s))
    )
  )

(define-test open-uri/base64
  (with-open-uri (s (concat "data:text/plain; charset=UTF-8;base64," (delete #\LFD (si:base64-encode (utf8 "‚ ‚¢‚¤")))))
    (assert-equal "‚ ‚¢‚¤" (read-all s))
    (assert-equal "text/plain" (content-type s))
    (assert-equal "utf-8" (charset s))
    )
  (with-open-uri (s (concat "data:text/plain;base64," (delete #\LFD (si:base64-encode (utf8 "‚ ‚¢‚¤")))))
    (assert-equal "‚ ‚¢‚¤" (read-all s *encoding-utf8n*))
    (assert-equal "text/plain" (content-type s))
    (assert-equal nil (charset s))
    )
  )

(define-test open-uri/base64-gif
  (with-open-uri (s (concat "data:image/gif;base64,R0lGODdhMAAwAPAAAAAAAP///ywAAAAAMAAw"
                            "AAAC8IyPqcvt3wCcDkiLc7C0qwyGHhSWpjQu5yqmCYsapyuvUUlvONmOZtfzgFz"
                            "ByTB10QgxOR0TqBQejhRNzOfkVJ+5YiUqrXF5Y5lKh/DeuNcP5yLWGsEbtLiOSp"
                            "a/TPg7JpJHxyendzWTBfX0cxOnKPjgBzi4diinWGdkF8kjdfnycQZXZeYGejmJl"
                            "ZeGl9i2icVqaNVailT6F5iJ90m6mvuTS4OK05M0vDk0Q4XUtwvKOzrcd3iq9uis"
                            "F81M1OIcR7lEewwcLp7tuNNkM3uNna3F2JQFo97Vriy/Xl4/f1cf5VWzXyym7PH"
                            "hhx4dbgYKAAA7"))
    (assert-equal "image/gif" (content-type s))
    (assert-equal nil (charset s))
    (with-open-file (s2 "larry.gif" :direction :input :encoding :binary)
      (assert-equal (read-all s2)
          (read-all s *encoding-binary*)))
    )
  )
