# xl-open-uri.core-extensions API Reference

  * [PACKAGES](#packages)
    * [xl-open-uri.core-extensions](#xl-open-uri.core-extensions)
  * [FUNCTIONS](#functions)
    * [install](#install)
    * [uninstall](#uninstall)

----

## <a name="packages">PACKAGES</a>

### Package: <a name="xl-open-uri.core-extensions"><em>xl-open-uri.core-extensions</em></a>

デフォルトの open と with-open-file を URI 対応に拡張するためのパッケージです。

ニックネームは以下のとおりです。

  * `open-uri.core-extensions`
  * `xl-open-uri.ext`
  * `open-uri.ext`


----

## <a name="functions">FUNCTIONS</a>

### Function: <a name="install"><em>install</em></a> <i>&optional (`PACKAGE` \*package\*)</i>

open と with-open-file を URI に対応した関数に置き換えます。
lisp:open を上書きするのではなく shadowing-import します。

```lisp
user> (open "http://www.google.co.jp/")
http://www.google.co.jp/
指定されたファイルが見つかりません。

user> (open-uri.ext:install)
nil

user> (open "http://www.google.co.jp/")
#<general-input-stream 75240380>
```

### Function: <a name="uninstall"><em>uninstall</em></a> <i>&optional (`PACKAGE` \*package\*)</i>

open と with-open-file を元の関数に置き換えます。

```lisp
user> (open "http://www.google.co.jp/")
#<general-input-stream 75240248>

user> (open-uri.ext:uninstall)
nil

user> (open "http://www.google.co.jp/")
http://www.google.co.jp/
指定されたファイルが見つかりません。
```
