# xl-open-uri - open-uri for xyzzy Lisp.

* Home URL: http://miyamuko.s56.xrea.com/xyzzy/xl-open-uri/intro.htm
* Version: 0.0.1


## SYNOPSIS

```lisp
user> (require "open-uri")
t

user> (with-open-stream (f (open-uri:open-uri "http://www.ruby-lang.org/"))
        (loop
          (format t "~A~%" (or (read-line f nil nil)
                               (return)))))
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

;; open と with-open-file を URI 対応にする
user> (open-uri.ext:install)
nil

;; Content-Encoding の取得 (gzip の展開は自動的には行われません)
user> (with-open-file (f "http://www.yahoo.co.jp/"
                         :headers '(:Accept-Encoding "gzip, deflate"))
        (open-uri:content-encoding f))
("gzip")

;; HEAD リクエストの送信
user> (with-open-file (f "http://www.jsdlab.co.jp/~kamei/cgi-bin/download.cgi"
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

;; data URL の読み込み
user> (open-uri:with-open-uri (s "data:text/plain; charset=utf-8,xyzzy%20%E8%AA%AD%E3%81%BF%E6%96%B9")
        (values (open-uri:base-uri s)
                (open-uri:content-type s)
                (open-uri:charset s)
                (open-uri:read-all s)))
"data:text/plain; charset=utf-8,xyzzy%20%E8%AA%AD%E3%81%BF%E6%96%B9" ;
"text/plain" ;
"utf-8" ;
"xyzzy 読み方"
```


## DESCRIPTION

xl-open-uri は Ruby の [open-uri] を xyzzy Lisp に移植したライブラリです。
HTTP/HTTPS に簡単にアクセスするための機能を提供します。

なお、xl-open-uri は FTP はサポートしていません。

  [open-uri]: http://doc.ruby-lang.org/ja/1.9.3/library/open=2duri.html


## INSTALL

1. [NetInstaller] で xl-open-uri, http-client, xl-winhttp, xl-alexandria, ansi-loop, ansify, setf-values
   をインストールします。

2. xl-open-uri はライブラリであるため自動的にロードはされません。
   必要な時点で require してください。

  [NetInstaller]: http://www7a.biglobe.ne.jp/~hat/xyzzy/ni.html


## REFERENCE

* references/ 配下を見てください。


## TODO

* FTP サポート?


## KNOWN BUGS

なし。

要望やバグは [GitHub Issues] か [@miyamuko] まで。

  [GitHub Issues]: http://github.com/miyamuko/xl-open-uri/issues
  [@miyamuko]: http://twitter.com/home?status=%40miyamuko%20%23xyzzy%20xl-open-uri%3a%20


## AUTHOR

みやむこ かつゆき (<mailto:miyamuko@gmail.com>)


## COPYRIGHT

xl-open-uri は MIT/X ライセンスに従って本ソフトウェアを使用、再頒布することができます。

    Copyright (c) 2012 MIYAMUKO Katsuyuki.

    Permission is hereby granted, free of charge, to any person obtaining
    a copy of this software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:

    The above copyright notice and this permission notice shall be
    included in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
    NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
    LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
    OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
    WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
