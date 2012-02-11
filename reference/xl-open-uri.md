# xl-open-uri.api API Reference

  * [PACKAGES](#packages)
    * [xl-open-uri](#xl-open-uri)
  * [MACROS](#macros)
    * [with-open-uri](#with-open-uri)
  * [FUNCTIONS](#functions)
    * [open-uri](#open-uri)
    * [close-uri](#close-uri)
    * [read-all](#read-all)
    * [read-block](#read-block)
    * [read-partial](#read-partial)
    * [base-uri](#base-uri)
    * [charset](#charset)
    * [content-encoding](#content-encoding)
    * [content-type](#content-type)
    * [last-modified](#last-modified)
    * [meta](#meta)
    * [status](#status)
    * [xl-open-uri-version](#xl-open-uri-version)

----

## <a name="packages">PACKAGES</a>

### Package: <a name="xl-open-uri.api"><em>xl-open-uri</em></a>

xl-open-uri の API を定義するパッケージです。

ニックネームは以下のとおりです。

  * `open-uri.api`
  * `xl-open-uri`
  * `open-uri`

__See Also:__

  * xl-open-uri.extensions
  * xl-open-uri.protocols


----

## <a name="macros">MACROS</a>

### Macro: <a name="with-open-uri"><em>with-open-uri</em></a> <i>(`STREAM` `URI` &rest `OPTIONS`) &body `BODY`</i>

指定した `URI` からストリームを作成し、本体を評価します。

  * `STREAM`    : ストリームに束縛される変数
  * `URI`       : ストリームを作成する URL
  * `OPTIONS`   : キーワード引数。[open-uri](#open-uri) へ渡せるものと同じ
  * `BODY`      : 実行する本体

使用例：

```lisp
user> (open-uri:with-open-uri (f "http://www.ruby-lang.org/"
                                 :headers '(:Accept-Language "ja, en"))
        (values (multiple-value-list (open-uri:status f))
                (open-uri:meta f)
                (open-uri:meta f :server)
                (open-uri:base-uri f)
                (open-uri:content-type f)
                (open-uri:charset f)))
(200 "OK") ;
(("Connection" . "Keep-Alive") ("Date" . "Thu, 09 Feb 2012 12:42:18 GMT") ...) ;
"Apache/2.2.3 (Debian) DAV/2 SVN/1.4.2 mod_ruby/1.2.6 Ruby/1.8.5(2006-08-25)" ;
"http://www.ruby-lang.org/ja/" ;
"text/html" ;
"utf-8"
```

__See Also:__

  * [open-uri](#open-uri)
  * [close-uri](#close-uri)
  * [read-all](#read-all)
  * [read-block](#read-block)
  * [read-partial](#read-partial)
  * [base-uri](#base-uri)
  * [charset](#charset)
  * [content-encoding](#content-encoding)
  * [content-type](#content-type)
  * [last-modified](#last-modified)
  * [meta](#meta)
  * [status](#status)


----

## <a name="functions">FUNCTIONS</a>


### Function: <a name="open-uri"><em>open-uri</em></a> <i>`URI` &rest `OPTIONS`</i>

指定した `URI` からストリームを作成します。
指定できる引数は URL スキームによって変わります。

ストリームからは以下の関数でメタ情報を取得することができます。

  * [base-uri](#base-uri)
  * [charset](#charset)
  * [content-encoding](#content-encoding)
  * [content-type](#content-type)
  * [last-modified](#last-modified)
  * [meta](#meta)
  * [status](#status)

また、ストリームからデータを読み込むには以下の関数を利用します。

  * [read-all](#read-all)
  * [read-block](#read-block)
  * [read-partial](#read-partial)
  * peek-char
  * read
  * read-as-string
  * read-char
  * read-char-no-hang
  * read-delimited-list
  * read-into
  * read-line
  * read-line-into
  * read-preserving-whitespace
  * unread-char

#### <a name="open-uri-http">HTTP/HTTPS</a>

以下のキーワード引数が指定できます。

  * `:method`
  * `:headers`
  * `:query`
  * `:body`
  * `:encoding`
  * `:response-encoding`
  * `:auth`
  * `:proxy-auth`
  * `:proxy`
  * `:no-redirect`

`:response-encoding` は [http-general-receiver] の `:encoding` 引数に指定されます。

それ以外の引数は [http-request] に渡せるものと同じです。

なお、 `:receiver`, `:wait`, `:oncomplete`, `:onprogress`, `:onabort`, `:onerror`
については指定できません。

  [http-request]: https://github.com/miyamuko/http-client/blob/master/reference/http-client.md#http-request
  [http-general-receiver]: https://github.com/miyamuko/http-client/blob/master/reference/http-client.md#http-general-receiver


```lisp
;; GET リクエストの送信
user> (open-uri:with-open-uri (f "http://www.ruby-lang.org/")
        (format t "~A" (open-uri:read-all f)))
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN"
...
nil

;; メタ情報の取得
user> (open-uri:with-open-uri (f "http://www.ruby-lang.org/"
                                 :headers '(:Accept-Language "ja, en"))
        (values (multiple-value-list (open-uri:status f))
                (open-uri:meta f)
                (open-uri:meta f :content-length)
                (open-uri:base-uri f)
                (open-uri:content-type f)
                (open-uri:charset f)))
(200 "OK") ;
(("Connection" . "Keep-Alive") ("Date" . "Thu, 09 Feb 2012 12:42:18 GMT") ...) ;
nil ;
"http://www.ruby-lang.org/ja/" ;
"text/html" ;
"utf-8"

;; HEAD リクエストの送信
user> (open-uri:with-open-uri (f "http://www.jsdlab.co.jp/~kamei/cgi-bin/download.cgi"
                                 :method "HEAD")
        (decode-universal-time
         (open-uri:last-modified f)))
21 ;
28 ;
1 ;
8 ;
12 ;
2005 ;
3 ;
nil ;
-9
```


----

#### <a name="open-uri-ftp">FTP</a>

以下のキーワード引数が指定できます。

  * `:direction`

    ストリームの入出力の方向を指定します。

    * `:input`: FTP からダウンロードします。
    * `:output`: FTP にアップロードします。

    デフォルトは `:input` です。

  * `:if-exists`

    FTP アップロード時 (`:direction` が `:output`) にファイルが存在する場合の動作を指定します。

    * `:error`: エラーを出力します。
    * `:append`: 既存ファイルに追加します (APPE コマンド)。
    * `:overwrite`: 上書きします (STOR コマンド)。
    * `:uniq`: 重複しないユニークなファイル名に変更します (STOU コマンド)。
      変更後のファイル名は base-uri で取得します。
      ※ FTP サーバによっては変更後の名前を取得できない場合があります。

  * `:encoding`

    `:binary` または `:text` を指定します。

    * `:binary`: バイナリモードで転送します。
    * `:text`: ASCII モードで転送します。

    デフォルトは `:binary` です。

  * `:auth`

    FTP の認証情報をユーザ名とパスワードのリストで指定します。

    ```lisp
    :auth '("anonymous" "anonymous@bar.com")
    :auth '("user" "password")
    ```

    デフォルトは `'("anonymous" nil)` です。

    ※ HTTP/HTTPS の場合と指定方法が違います。

  * `:active-mode`

    `non-nil` を指定した場合、FTP のパッシブモードを利用しません。

    デフォルトは `nil` です。

  * `:logger`

    FTP コマンドの実行結果を記録する output-stream を指定します。

    * t を指定した場合は *standard-output* に出力します。
    * `nil` を指定した場合は何も出力しません。

    デフォルトは `nil` です。

    ```lisp
    :logger nil                                                ; ログを出力しない
    :logger t                                                  ; *standard-output* に出力する
    :logger *status-window*                                    ; メッセージウィンドウに出力する
    :logger (make-buffer-stream (get-buffer-create "ftp-log")) ; バッファに出力する
    ```

```lisp
;; FTP upload
user> (open-uri:with-open-uri (s "ftp://my.ftp-server.com/public_html/hello.txt"
                                 :direction :output
                                 :auth '("user" "password")
                                 :encoding :text
                                 :logger t)
        (format s "Hello World~%"))
R: 220 ProFTPD
S: USER user
R: 331 Password required for user
S: PASS *****
R: 230 User user logged in
S: PASV
R: 227 Entering Passive Mode (*****).
S: NLST /public_html/
R: 150 Opening ASCII mode data connection for file list
R: 226 Transfer complete
S: PASV
R: 227 Entering Passive Mode (*****).
S: STOR /public_html/hello.txt
R: 150 Opening ASCII mode data connection for /public_html/hello.txt
R: 226 Transfer complete
S: QUIT
R: 221 Goodbye.
nil

;; FTP download
user> (open-uri:with-open-uri (s "ftp://my.ftp-server.com/public_html/hello.txt"
                                 :direction :input
                                 :auth '("user" "password")
                                 :encoding :text
                                 :logger t)
        (values (open-uri:read-all s)
          (format-date-string "%Y/%m/%d %H:%M:%S" (open-uri:last-modified s))))
R: 220 ProFTPD
S: USER user
R: 331 Password required for user
S: PASS *****
R: 230 User user logged in
S: PASV
R: 227 Entering Passive Mode (*****).
S: NLST /public_html/
R: 150 Opening ASCII mode data connection for file list
R: 226 Transfer complete
S: MDTM /public_html/hello.txt
R: 213 20120211063509
S: PASV
R: 227 Entering Passive Mode (*****).
S: RETR /public_html/hello.txt
R: 150 Opening ASCII mode data connection for /public_html/hello.txt (12 bytes)
R: 226 Transfer complete
S: QUIT
R: 221 Goodbye.
"Hello World
"
"2012/02/11 12:38:30"
```


----

#### <a name="open-uri-data">DATA</a>

引数は URI のみです。

```lisp
;; data URL の読み込み (url encode)
user> (open-uri:with-open-uri (s "data:text/plain;charset=utf-8,xyzzy%20%E8%AA%AD%E3%81%BF%E6%96%B9")
        (values (open-uri:base-uri s)
                (open-uri:content-type s)
                (open-uri:charset s)
                (open-uri:read-all s)))
"data:text/plain; charset=utf-8,xyzzy%20%E8%AA%AD%E3%81%BF%E6%96%B9" ;
"text/plain" ;
"utf-8" ;
"xyzzy 読み方"

;; data URL の読み込み (base64)
user> (open-uri:with-open-uri (s (concat "data:image/gif;base64,R0lGODdhMAAwAPAAAAAAAP///ywAAAAAMAAw"
                                         "AAAC8IyPqcvt3wCcDkiLc7C0qwyGHhSWpjQu5yqmCYsapyuvUUlvONmOZtfzgFz"
                                         "ByTB10QgxOR0TqBQejhRNzOfkVJ+5YiUqrXF5Y5lKh/DeuNcP5yLWGsEbtLiOSp"
                                         "a/TPg7JpJHxyendzWTBfX0cxOnKPjgBzi4diinWGdkF8kjdfnycQZXZeYGejmJl"
                                         "ZeGl9i2icVqaNVailT6F5iJ90m6mvuTS4OK05M0vDk0Q4XUtwvKOzrcd3iq9uis"
                                         "F81M1OIcR7lEewwcLp7tuNNkM3uNna3F2JQFo97Vriy/Xl4/f1cf5VWzXyym7PH"
                                         "hhx4dbgYKAAA7"))
        (values (open-uri:content-type s)
                (open-uri:charset s)
                (open-uri:read-block s 6)))
"image/gif"
nil
"GIF87a"
```


__See Also:__

  * [with-open-uri](#with-open-uri)
  * [close-uri](#close-uri)
  * [read-all](#read-all)
  * [read-block](#read-block)
  * [read-partial](#read-partial)
  * [base-uri](#base-uri)
  * [charset](#charset)
  * [content-encoding](#content-encoding)
  * [content-type](#content-type)
  * [last-modified](#last-modified)
  * [meta](#meta)
  * [status](#status)
  * with-open-stream
  * http-request


### Function: <a name="close-uri"><em>close-uri</em></a> <i>`STREAM` &key `:abort`</i>

指定したストリームを閉じます。
open-uri でオープしたストリームは、通常の close ではなくこの関数で閉じてください。

__See Also:__

  * [open-uri](#open-uri)


### Function: <a name="read-all"><em>read-all</em></a> <i>`STREAM` &optional `ENCODING` (`EOF-ERROR-P` t) `EOF-VALUE`</i>

指定したストリームから EOF までのすべてのデータを読み込んで文字列で返します。

  * `ENCODING` を指定した場合、読み込んだ文字列を指定したエンコーディングに変換します。
  * `EOF-ERROR-P` に `non-nil` を指定した場合、入力ストリームが終端に達しているとエラーを通知します。
  * `EOF-VALUE` には入力ストリームが最初から終端に達していた場合の戻り値を指定します。

__See Also:__

  * [read-block](#read-block)
  * [read-partial](#read-partial)


### Function: <a name="read-block"><em>read-block</em></a> <i>`STREAM` `MAX-LENGTH` &optional (`EOF-ERROR-P` t) `EOF-VALUE` `BUFFER`</i>

指定したストリームから `MAX-LENGTH` 文字のデータを読み込んで文字列で返します。
EOF を読まない限り、`MAX-LENGTH` のデータを読むまで待ちます。

  * `STREAM` に十分なデータが無い場合、 返される文字列は `MAX-LENGTH` より短いかもしれません。
  * `MAX-LENGTH` が 0 の場合は、常に空文字列が返されます。
  * `EOF-ERROR-P` に `non-nil` を指定した場合、入力ストリームが終端に達しているとエラーを通知します。
  * `EOF-VALUE` には入力ストリームが最初から終端に達していた場合の戻り値を指定します。
  * `BUFFER` には文字列を読み込むバッファを指定します。
    * 何も指定しなかった場合は毎回バッファを確保します。
    * `BUFFER` のサイズより `MAX-LENGTH` が大きい場合はエラーが発生します。

__See Also:__

  * [read-all](#read-all)
  * [read-partial](#read-partial)


### Function: <a name="read-partial"><em>read-partial</em></a> <i>`STREAM` `MAX-LENGTH` &optional (`EOF-ERROR-P` t) `EOF-VALUE`</i>

指定したストリームから `MAX-LENGTH` 文字のデータを読み込んで文字列で返します。
EOF が読まれなくても、すぐに読めるデータが `MAX-LENGTH` よりも少ない場合はそのデータだけを返します。

  * `STREAM` に十分なデータが無い場合、 返される文字列は `MAX-LENGTH` より短いかもしれません。
  * `MAX-LENGTH` が 0 の場合は、常に空文字列が返されます。
  * `EOF-ERROR-P` に `non-nil` を指定した場合、入力ストリームが終端に達しているとエラーを通知します。
  * `EOF-VALUE` には入力ストリームが最初から終端に達していた場合の戻り値を指定します。

__See Also:__

  * [read-all](#read-all)
  * [read-block](#read-block)


### Function: <a name="base-uri"><em>base-uri</em></a> <i>`STREAM`</i>

サポートする URL スキーム: すべて

リソースの実際の URI を返します。
リダイレクトされた場合は、リダイレクト後の URI を返します。

```lisp
xl-open-uri> (with-open-stream (s (open-uri:open-uri "http://www.jsdlab.co.jp/~kamei/cgi-bin/download.cgi"))
               (open-uri:base-uri s))
"http://www.mars.dti.ne.jp/~t-kamei/xyzzy/xyzzy-0.2.2.235.lzh"
```


### Function: <a name="charset"><em>charset</em></a> <i>`STREAM`</i>

サポートする URL スキーム: HTTP/HTTPS, DATA

Content-Type ヘッダの charset を返します。
文字列は小文字へと変換されています。

Content-Type ヘッダがない場合は、nil を返します。

```lisp
xl-open-uri> (with-open-stream (s (open-uri:open-uri "http://www.jsdlab.co.jp/~kamei/cgi-bin/download.cgi"))
               (values (open-uri:charset s)
                       (open-uri:meta s :content-type)))
nil ;
"application/x-lha"

xl-open-uri> (with-open-stream (s (open-uri:open-uri "http://www.jsdlab.co.jp/~kamei/"))
               (values (open-uri:charset s)
                       (open-uri:meta s :content-type)))
"iso-8859-1"
"text/html"

xl-open-uri> (with-open-stream (s (open-uri:open-uri "http://www.google.co.jp/"))
               (values (open-uri:charset s)
                       (open-uri:meta s :content-type)))
"shift_jis" ;
"text/html; charset=Shift_JIS"
```


### Function: <a name="content-encoding"><em>content-encoding</em></a> <i>`STREAM`</i>

サポートする URL スキーム: HTTP/HTTPS

対象となるリソースの Content-Encoding を文字列のリストとして返します。
文字列は小文字へと変換されています。

Content-Encoding ヘッダがない場合は、`nil` を返します。

```lisp
xl-open-uri> (with-open-stream (s (open-uri:open-uri "http://www.yahoo.co.jp/"
                                                     :headers '(:Accept-Encoding "gzip")))
               (open-uri:content-encoding s))
("gzip")
```


### Function: <a name="content-type"><em>content-type</em></a> <i>`STREAM`</i>

サポートする URL スキーム: HTTP/HTTPS, DATA

対象となるリソースの Content-Type を文字列で返します。
文字列は小文字へと変換されています。

Content-Type ヘッダがない場合は、"application/octet-stream" を返します。

```lisp
xl-open-uri> (with-open-stream (s (open-uri:open-uri "http://www.jsdlab.co.jp/~kamei/cgi-bin/download.cgi"))
               (values (open-uri:content-type s)
                       (open-uri:meta s :content-type)))
"application/x-lha" ;
"application/x-lha"

xl-open-uri> (with-open-stream (s (open-uri:open-uri "http://www.google.co.jp/"))
               (values (open-uri:content-type s)
                       (open-uri:meta s :content-type)))
"text/html; charset=Shift_JIS" ;
"text/html"
```


### Function: <a name="last-modified"><em>last-modified</em></a> <i>`STREAM`</i>

サポートする URL スキーム: HTTP/HTTPS, FTP

対象となる URI の最終更新時刻を universal-time で返します。
Last-Modified ヘッダがない場合は `nil` を返します。

```lisp
xl-open-uri> (with-open-stream (s (open-uri:open-uri "http://www.jsdlab.co.jp/~kamei/cgi-bin/download.cgi"))
               (values (open-uri:last-modified s)
                       (open-uri:meta s :last-modified)))
3342961701 ;
"Wed, 07 Dec 2005 16:28:21 GMT"
```


### Function: <a name="meta"><em>meta</em></a> <i>`STREAM` &optional `KEY`</i>

サポートする URL スキーム: HTTP/HTTPS

`KEY` を指定した場合は指定したヘッダを返します。
`KEY` を指定しなかった場合はすべてのヘッダを alist で返します。

```lisp
xl-open-uri> (with-open-stream (s (open-uri:open-uri "http://www.hatena.ne.jp/"))
               (values (open-uri:meta s :x-framework)
                       (open-uri:meta s :server)
                       (open-uri:meta s)))
"Hatena/2.0" ;
"Apache/2.2.3 (CentOS)" ;
(("Cache-Control" . "private") ("Connection" . "Keep-Alive") ...)
```


### Function: <a name="status"><em>status</em></a> <i>`STREAM`</i>

サポートする URL スキーム: HTTP/HTTPS

対象となるリソースのステータスコードと reason phrase を多値で返します。

```lisp
xl-open-uri> (with-open-stream (s (open-uri:open-uri "http://www.google.co.jp/"
                                                     :method "DELETE"))
               (open-uri:status s))
405 ;
"Method Not Allowed"
```


### Function: <a name="xl-open-uri-version"><em>xl-open-uri-version</em></a>

本ライブラリのバージョンを文字列で返します。

```lisp
xl-open-uri> (xl-open-uri-version)
"0.0.1"
```
