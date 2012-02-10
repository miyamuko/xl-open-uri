; -*- mode: lisp; package: xl-open-uri.test.helper; encoding: shift_jis -*-

(require "lisp-unit")

(defpackage :xl-open-uri.test.helper
  (:use :lisp :editor :lisp-unit
   )
  )

(in-package :xl-open-uri.test.helper)

(export '($
          utf8
          euc
          sjis
          bin
          md5-file
          assert-string-match
          ))

(defun user::runall-xl-open-uri-test ()
  (interactive)
  (dolist (src (directory "." :wild "*.l" :recursive t))
    (load src))
  (let ((test-pkgs (remove-if #'(lambda (pkg)
                                  (or (not (string-match "^xl-open-uri.test." (package-name pkg)))
                                      (string-match "^xl-open-uri.test.helper" (package-name pkg))))
                              (list-all-packages))))
    (let ((*trace-output* (lisp-unit::%get-result-buffer-stream)))
      (dolist (pkg test-pkgs)
        (let ((pkg-name (package-name pkg)))
          (fresh-line *trace-output*)
          (format *trace-output* "~%=== ~A ===~%" pkg-name)
          (message pkg-name)
          (let ((*package* pkg))
            (lisp-unit:run-tests)
            (do-events))
          )))))


(defun $ (obj &rest keys)
  (reduce #'(lambda (o k)
              (cdr (assoc k o :test #'string-equal)))
          keys
          :initial-value obj))

(defun utf8 (str)
  (when str
    (convert-encoding-from-internal *encoding-utf8n* str)))

(defun euc (str)
  (when str
    (convert-encoding-from-internal *encoding-euc-jp* str)))

(defun sjis (str)
  (when str
    (convert-encoding-from-internal *encoding-sjis* str)))

(defun bin (str)
  (when str
    (convert-encoding-to-internal *encoding-binary* str)))

(defun md5-file (file)
  (with-open-file (s file :direction :input :encoding :binary)
    (si:md5 s)))

(defmacro assert-string-match (expected form &rest extras)
  (lisp-unit::expand-assert :equal form form expected extras :test #'string-match))


(provide "xl-open-uri/test/helper")

;;; End
