# xl-open-uri.protocols API Reference

  * [PACKAGES](#packages)
    * [xl-open-uri.protocols](#xl-open-uri.protocols)
  * [FUNCTIONS](#functions)
    * [add-protocol-handler](#add-protocol-handler)
    * [remove-protocol-handler](#remove-protocol-handler)
    * [find-protocol-handler](#find-protocol-handler)
    * [parse-content-type](#parse-content-type)
    * [split-token](#split-token)

----

## <a name="packages">PACKAGES</a>

### Package: <a name="xl-open-uri.protocols"><em>xl-open-uri.protocols</em></a>

xl-open-uri �ɔC�ӂ̃v���g�R���n���h����ǉ����邽�߂̋@�\��񋟂���p�b�P�[�W�ł��B
�v���g�R���n���h���̊J���җp�̃p�b�P�[�W�ł��B

�j�b�N�l�[���͈ȉ��̂Ƃ���ł��B

  * `open-uri.protocols`

�v���g�R���n���h���͈ȉ��̊֐����`�����p�b�P�[�W�Ƃ��č쐬���܂��B
`open-uri` �ȊO�͎����� optional �ł��B
���ꂼ��ȉ��̂悤�Ɏ������Ă��������B

  * `open-uri` `URI` &rest `OPTIONS` (�K�{)

    open-uri:open-uri �Ɏw�肵�����������̂܂܎w�肳��܂��B
    �߂�l�� stream �� context �𑽒l�ŕԂ��܂��B

    context �͔C�ӂ̒l��Ԃ����Ƃ��ł��A�ȉ��̊֐��̈����Ɏw�肳��܂��B

  * `close-uri` `STREAM` `CONTEXT` &key `:abort`

    open-uri:close-uri ���Ă΂ꂽ�Ƃ��ɌĂяo����܂��B

    `STREAM` �� `close` ���ꂽ��ԂŌĂяo�����̂�
    ���̑��̏I���������K�v�Ȃ�������Ă��������B

  * `meta` `STREAM` `CONTEXT` &optional `KEY`

    open-uri:meta ���Ă΂ꂽ�Ƃ��ɌĂяo����܂��B

  * `status` `STREAM` `CONTEXT`

    open-uri:status ���Ă΂ꂽ�Ƃ��ɌĂяo����܂��B

  * `base-uri` `STREAM` `CONTEXT`

    open-uri:base-uri ���Ă΂ꂽ�Ƃ��ɌĂяo����܂��B

  * `content-encoding` `STREAM` `CONTEXT`

    open-uri:content-encoding ���Ă΂ꂽ�Ƃ��ɌĂяo����܂��B

  * `content-type` `STREAM` `CONTEXT`

    open-uri:content-type ���Ă΂ꂽ�Ƃ��ɌĂяo����܂��B

  * `charset` `STREAM` `CONTEXT`

    open-uri:charset ���Ă΂ꂽ�Ƃ��ɌĂяo����܂��B

  * `last-modified` `STREAM` `CONTEXT`

    open-uri:last-modified ���Ă΂ꂽ�Ƃ��ɌĂяo����܂��B


### ������

```lisp
(defpackage :eval-protocol-handler
  (:use
   :lisp
   :editor
   :open-uri.protocols))

(in-package :eval-protocol-handler)

(defun open-uri (uri)
  (unless (string-match "eval:\\(.+\\)" uri)
    (error "Invalid URL: ~A" uri))
  (values (make-string-input-stream
           (with-output-to-string (s)
             (let ((*standard-output* s))
               (let ((r (multiple-value-list
                         (eval
                          (read-from-string (match-string 1))))))
                 (fresh-line)
                 (format t "~{~A~^ ;~%~}" r)))))
          uri))

(defun base-uri (stream uri)
  uri)

(add-protocol-handler :eval :eval-protocol-handler)
```

���s���ʂ͈ȉ��̂Ƃ���ł��B

```lisp
user> (open-uri:with-open-uri (s "eval:(progn (princ \"Hello\") (values (+ 1 2) (* 3 4)))")
        (values (open-uri:base-uri s)
                (open-uri:read-all s)))
"eval:(progn (princ \"Hello\") (values (+ 1 2) (* 3 4)))" ;
"Hello
3 ;
12"
```


----

## <a name="functions">FUNCTIONS</a>

### Function: <a name="add-protocol-handler"><em>add-protocol-handler</em></a> <i>`SCHEME` `PACKAGE`</i>

�w�肳�ꂽ URL �X�L�[�}�̃v���g�R���n���h����ݒ肵�܂��B
���łɃv���g�R���n���h�����ݒ肳��Ă���ꍇ�͏㏑�����܂��B

__See Also:__

  * [xl-open-uri.protocols](#xl-open-uri.protocols)
  * [find-protocol-handler](#find-protocol-handler)
  * [remove-protocol-handler](#remove-protocol-handler)


### Function: <a name="find-protocol-handler"><em>find-protocol-handler</em></a> <i>`SCHEME`</i>

�w�肳�ꂽ URL �X�L�[�}�̃v���g�R���n���h�����擾���܂��B
�߂�l�̓p�b�P�[�W�ł��B

__See Also:__

  * [xl-open-uri.protocols](#xl-open-uri.protocols)
  * [add-protocol-handler](#add-protocol-handler)
  * [remove-protocol-handler](#remove-protocol-handler)


### Function: <a name="remove-protocol-handler"><em>remove-protocol-handler</em></a> <i>`SCHEME`</i>

�w�肳�ꂽ URL �X�L�[�}�̃v���g�R���n���h�����폜���܂��B

__See Also:__

  * [xl-open-uri.protocols](#xl-open-uri.protocols)
  * [add-protocol-handler](#add-protocol-handler)
  * [find-protocol-handler](#find-protocol-handler)


### Function: <a name="parse-media-type"><em>parse-media-type</em></a> <i>`CONTENT-TYPE`</i>

MIME �^�C�v����͂��� content-type, charset, encoding �𑽒l�ŕԂ��܂��B

```lisp
xl-open-uri.protocols> (parse-media-type "text/html")
"text/html" ;
nil ;
nil

xl-open-uri.protocols> (parse-media-type "text/html; charset=utf-8")
"text/html" ;
"utf-8" ;
#.(make-utf8-encoding "utf8n" "Unicode (UTF-8N)" :signature nil :windows t :byte-order nil :cjk :jp)

xl-open-uri.protocols> (parse-media-type "text/html; charset=hoge")
"text/html" ;
"hoge" ;
nil
```

### Function: <a name="split-token"><em>split-token</em></a> <i>`HEADER` &optional (`SEPARATOR` #\\,)</i>

��������w�肳�ꂽ�Z�p���[�^�ŕ������܂��B
�Z�p���[�^�̃f�t�H���g�l�̓J���}�ł��B

```lisp
xl-open-uri.protocols> (split-token "gzip, deflate")
("gzip" "deflate")
```
