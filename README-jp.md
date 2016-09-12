# MKDocs on Docker

## 概要

所定のディレクトリに配置した Markdown ファイルから HTML を生成し WEB サイトを自動構築します。コンテナには WEB サーバー（Apache2）を含むため、生成された HTML は別途 WEB サーバーを用意することなく ``http://<コンテナの IP アドレス>`` で閲覧することが可能です。

また、GitHub などのレポジトリで Markdown ファイルを管理することにより、対象レポジトリの ``master`` ブランチへ ``push`` することにより、

1. レポジトリからの Markdown ファイルの取得
2. HTML の生成
3. WEB サーバーのドキュメントルートへデプロイ

を自動的に実行することも可能です。

## コンテナに含む主なコンポーネント

* [MKDocs](http://www.mkdocs.org/) - HTML 生成エンジン
* [Apache2](https://httpd.apache.org/) - Web サーバー
* [Git-Auto-Deploy](https://github.com/olipo186/Git-Auto-Deploy) - Web hook ハンドラ

## 使い方

### Step 1: コンテナの起動

以下のコマンドでコンテナを起動します。

```bash
docker run --name mkdocs -p 8000:80 -v $(pwd)/.docs:/mkdocs/docs -itd mkdocs 
```

* コンテナ内の ``/mkdocs/docs`` ディレクトリをホスト OS にマウントして起動します。``/mkdocs/docs`` は Markdown ファイルを配置するディレクトリです。

* コンテナが起動したら WEB ブラウザから ``http://<ホスト名>:8000`` にアクセスすると MKDocs のデフォルト画面が表示されます。

### Step 2: Markdown ファイルの設置

``docker run`` を実行したディレクトリに作成された ``.docs`` ディレクトリに Markdown ファイルを配置します。

* 配置する Markdown ファイルのファイル名に日本語は使えません。Markdown ファイル内で日本語は利用できます。
* ``/mkdocs/docs`` にフォルダで階層構造を作ると、生成される HTML のメニューが、フォルダ階層に従って構築されます。

### Step 3: HTML の生成

以下のコマンドを実行して、配置した Markdown ファイルから HTML を生成します。

```bash
docker exec -itd mkdocs mkdocs build --clean --config-file /mkdocs/mkdocs.yml mkdocs
```

* コマンドを実行後 ``http://<ホスト名>:8000`` にアクセスして HTML が更新されたことを確認します。
* 以降、Markdown ファイルを追加/削除/編集するたびに上記コマンドを実行することで HTML が再生成されます。

## レポジトリと関連付ける

Markdown ファイルを GitHub などのレポジトリで管理している場合、そのレポジトリと関連づけることで Markdown ファイルの追加/削除/編集後に、リポジトリの ``master`` ブランチへ ``push`` すると、自動的に、

1. リポジトリから Markdown ファイルの取得
2. 取得した Markdown ファイルから HTML の生成
3. WEB サーバーのドキュメントルートへデプロイ

を行います。

対応しているレポジトリは GitHub、GitLab、BitBucket 及び GitBucket の 4 種類です。

リポジトリと関連づけるには ``-p 8001:8001`` と ``-e GIT_CLONE_URL=<レポジトリの Clon URL>`` を追加してコンテナを起動させます。例えば、以下のようなコマンドでコンテナを起動させます。

```bash
docker run --name mkdocs -p 8000:80 -p 8001:8001 -v $(pwd)/.docs:/mkdocs/docs -e GIT_CLONE_URL=https://github.com/taro/documents.git -itd mkdocs 
```

レポジトリと関連付けてコンテナを起動した場合、コンテナ起動時にレポジトリから Markdown ファイルの取得、HTML 生成、WEB サーバードキュメントルートへの配置、が実行されるので、WEB ブラウザから ``http://<ホスト名>:8000`` へアクセスすると、生成された HTML が閲覧できます。

以降は Markdown ファイルをレポジトリの ``master`` ブランチへ ``push`` するたびに ``http;//<ホスト名>:8000`` の内容が自動更新されます。

## 環境変数

コンテナ起動時に以下のオプションを付与することによって HTML の生成内容などを変更することができます。

|変数|デフォルト値|指定する値|説明|
|:---|:---|:---|:---|
|GIT\_CLONE\_URL|なし|リポジトリの Clone URL|指定するとリポジトリと関連付けられる。リポジトリの Clone URL(``git clone xxx`` の ``xxx`` に該当するもの)であること。コンテナからアクセス可能な URL であること。|
|SITE\_NAME|My Document|任意の文字列|サイト名。\<head>タグ内の\<title>タグに設定される。|
|SITE\_URL|なし|サイトの URL|サイトのURL。\<head>タグ内の\<link>タグ（canonical）に設定される。|
|REPO\_URL|なし|リポジトリの URL|指定した場合、レポジトリへのリンクが生成される。<br>例:``REPO_URL=https://github.com/example/repository/``|
|REPO\_NAME|なし|任意の文字列|指定した場合、レポジトリへのリンクが生成される|
|SITE\_DESCRIPTION|なし|任意の文字列|サイト概要。\<head>タグ内の\<meta>タグに設定される。|
|SITE\_AUTHOR|なし|任意の文字列|指定した場合、フッタに著者情報として表示される|
|COPYRIGHT|なし|任意の文字列|指定した場合、フッタに著作権情報として表示される|
|SITE\_FAVICON|なし|``favicon.ico`` へのファイルパス|サイトのファビコン。例：``SITE_FAVICON=favicon.ico``。<br>``favicon.icon`` ファイルは ``/mkdocs/docs`` に配置し、``/mkdocs/docs`` からの相対パスで指定する。|
|GOOGLE\_ANALYTICS|なし|||
|THEME|mkdocs|mkdocs<br>readthedocs<br>bootstrap<br>amelia<br>cerulean<br>cosmo<br>cyborg<br>flatly<br>journal<br>readable<br>simplex<br>slate<br>spacelab<br>united<br>yeti|テーマの指定。[テーマサンプル](http://www.mkdocs.org/user-guide/styling-your-docs/)|

参考：<a href="http://www.mkdocs.org/user-guide/configuration/" target="_blank">Configuration - MkDocs</a>


## トラブルシューティング

### レポジトリから Markdown ファイルが取得できない

``-e GIT_CLONE_URL=xxx`` を付与してコンテナを起動した後に、コンテナの中に入って、``/Git-Auto-Deploy/docs_hook`` ディレクトリの存在を確認します。存在しない場合はレポジトリの初期取得（clone）に失敗しているので ``GIT_CLONE_URL=xxx`` を確認してください。

``GIT_CLONE_URL`` に指定する URL には、コンテナ内からアクセス可能な URL である必要があります。


## 設定ファイル

* MKDocs - ``/mkdocs/conf/mkdocs.yml``
* Git-Auto-Deploy - ``/Git-Auto-Devlop/conf/config.json``

##

## docker-compose.yml サンプル

以下の ``docker-compose.yml`` は ``GitBucket`` が含まれています。``GitBucket`` が必要ない場合は、``gitbucket`` と ``mariadb`` セクションを削除してください。

削除しない場合、 

1. ``docker-compose up -d gitbucket`` で ``gitbucket`` を起動
2. ``http://<gitbucket の URL>:8080`` でアクセス
3. ``root``/``root`` でログイン
4. ``documents`` との名称でレポジトリ作成
5. Markdown ファイルを ``master`` ブランチへ ``push``

をしたのち、``docker-compose up -d mkdocs`` で リポジトリと関連付いた状態で MKDocks が起動します。 

```bash
version: '2'
services:
    mkdocs:
        image: nutsllc/toybox-mkdocs:0.15.3
        volumes:
            - "./.data/mkdocs:/mkdocs/conf"
            - "./.data/webhook:/Git-Auto-Deploy/conf"
        environment:
            - GIT_CLONE_URL=http://gitbucket:8080/root/documents.git
        ports:
            - "8000:80"
            - "8001:8001"

    gitbucket:
        image: nutsllc/toybox-gitbucket:4.1.0
        depends_on:
            - mariadb
        links:
            - mariadb:mysql
        volumes:
            - "./.data/gitbucket:/gitbucket"
        ports:
            - "29418:29418"
            - "8080:8080"
    
    mariadb:
        image: nutsllc/toybox-mariadb:10.1.14
        volumes:
            - "./.data/mariadb:/var/lib/mysql"
        environment:
            - MYSQL_ROOT_PASSWORD=root
            - MYSQL_DATABASE=toybox_gitbucket
            - MYSQL_USER=toybox
            - MYSQL_PASSWORD=toybox
            - TERM=xterm
```