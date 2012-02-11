# xl-open-uri.extensions API Reference

  * [PACKAGES](#packages)
    * [xl-open-uri.extensions](#xl-open-uri.extensions)
  * [FUNCTIONS](#functions)
    * [install](#install)
    * [uninstall](#uninstall)

----

## <a name="packages">PACKAGES</a>

### Package: <a name="xl-open-uri.extensions"><em>xl-open-uri.extensions</em></a>

デフォルトの open と with-open-file を URI 対応に拡張するためのパッケージです。

ニックネームは以下のとおりです。

  * `open-uri.extensions`
  * `xl-open-uri.ext`
  * `open-uri.ext`

__See Also:__

  * xl-open-uri
  * xl-open-uri.extensions


----

## <a name="functions">FUNCTIONS</a>

### Function: <a name="install"><em>install</em></a> <i>&optional (`PACKAGE` \*package\*)</i>

open, close, with-open-file, with-open-stream を URI に対応した関数に置き換えます。

lisp パッケージの関数を上書きするのではなく shadowing-import します。

```lisp
user> (open "http://www.google.co.jp/")
http://www.google.co.jp/
指定されたファイルが見つかりません。

user> (open-uri.ext:install)
nil

user> (open "http://www.google.co.jp/")
#<general-input-stream 75240380>
```

__See Also:__

  * [uninstall](#uninstall)
  * open
  * close
  * open-uri
  * close-uri
  * with-open-file
  * with-open-stream
  * with-open-uri

### Function: <a name="uninstall"><em>uninstall</em></a> <i>&optional (`PACKAGE` \*package\*)</i>

[install](#install) で shadowing-import した関数を元の関数に戻します。

```lisp
user> (open "http://www.google.co.jp/")
#<general-input-stream 75240248>

user> (open-uri.ext:uninstall)
nil

user> (open "http://www.google.co.jp/")
http://www.google.co.jp/
指定されたファイルが見つかりません。
```

__See Also:__

  * [install](#install)
  * open
  * close
  * open-uri
  * close-uri
  * with-open-file
  * with-open-stream
  * with-open-uri
