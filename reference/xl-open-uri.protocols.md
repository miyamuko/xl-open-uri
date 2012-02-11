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

xl-open-uri に任意のプロトコルハンドラを追加するための機能を提供するパッケージです。
プロトコルハンドラの開発者用のパッケージです。

ニックネームは以下のとおりです。

  * `open-uri.protocols`

プロトコルハンドラは以下の関数を定義したパッケージとして作成します。
`open-uri` 以外は実装は optional です。
それぞれ以下のように実装してください。

  * `open-uri` `URI` &rest `OPTIONS` (必須)

    open-uri:open-uri に指定した引数がそのまま指定されます。
    戻り値は stream と context を多値で返します。

    context は任意の値を返すことができ、以下の関数の引数に指定されます。

  * `close-uri` `STREAM` `CONTEXT` &key `:abort`

    open-uri:close-uri が呼ばれたときに呼び出されます。

    `STREAM` は `close` された状態で呼び出されるので
    その他の終了処理が必要なら実装してください。

  * `meta` `STREAM` `CONTEXT` &optional `KEY`

    open-uri:meta が呼ばれたときに呼び出されます。

  * `status` `STREAM` `CONTEXT`

    open-uri:status が呼ばれたときに呼び出されます。

  * `base-uri` `STREAM` `CONTEXT`

    open-uri:base-uri が呼ばれたときに呼び出されます。

  * `content-encoding` `STREAM` `CONTEXT`

    open-uri:content-encoding が呼ばれたときに呼び出されます。

  * `content-type` `STREAM` `CONTEXT`

    open-uri:content-type が呼ばれたときに呼び出されます。

  * `charset` `STREAM` `CONTEXT`

    open-uri:charset が呼ばれたときに呼び出されます。

  * `last-modified` `STREAM` `CONTEXT`

    open-uri:last-modified が呼ばれたときに呼び出されます。


### 実装例

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

実行結果は以下のとおりです。

```lisp
user> (open-uri:with-open-uri (s "eval:(progn (princ \"Hello\") (values (+ 1 2) (* 3 4)))")
        (values (open-uri:base-uri s)
                (open-uri:read-all s)))
"eval:(progn (princ \"Hello\") (values (+ 1 2) (* 3 4)))" ;
"Hello
3 ;
12"
```


__See Also:__

  * xl-open-uri
  * xl-open-uri.extensions


----

## <a name="functions">FUNCTIONS</a>

### Function: <a name="add-protocol-handler"><em>add-protocol-handler</em></a> <i>`SCHEME` `PACKAGE`</i>

指定された URL スキーマのプロトコルハンドラを設定します。
すでにプロトコルハンドラが設定されている場合は上書きします。

__See Also:__

  * [xl-open-uri.protocols](#xl-open-uri.protocols)
  * [find-protocol-handler](#find-protocol-handler)
  * [remove-protocol-handler](#remove-protocol-handler)


### Function: <a name="find-protocol-handler"><em>find-protocol-handler</em></a> <i>`SCHEME`</i>

指定された URL スキーマのプロトコルハンドラを取得します。
戻り値はパッケージです。

__See Also:__

  * [xl-open-uri.protocols](#xl-open-uri.protocols)
  * [add-protocol-handler](#add-protocol-handler)
  * [remove-protocol-handler](#remove-protocol-handler)


### Function: <a name="remove-protocol-handler"><em>remove-protocol-handler</em></a> <i>`SCHEME`</i>

指定された URL スキーマのプロトコルハンドラを削除します。

__See Also:__

  * [xl-open-uri.protocols](#xl-open-uri.protocols)
  * [add-protocol-handler](#add-protocol-handler)
  * [find-protocol-handler](#find-protocol-handler)


### Function: <a name="parse-media-type"><em>parse-media-type</em></a> <i>`CONTENT-TYPE`</i>

MIME タイプを解析して content-type, charset, encoding を多値で返します。

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

文字列を指定されたセパレータで分割します。
セパレータのデフォルト値はカンマです。

```lisp
xl-open-uri.protocols> (split-token "gzip, deflate")
("gzip" "deflate")
```
