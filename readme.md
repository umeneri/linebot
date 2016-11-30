
# 調査観点
ベンチ
twitter bot
chatwork api
slack bot


lineを使用する利点

lineで作ってみた

どんなAPIがあるか

# API
構造

rate limit

status code



[LINE Messaging API と AWS Lambda で LINE BOT を作ってみた](http://www.kazuweb.asia/aws/lambda/chatbot)

[材料やジャンルからオススメのレシピを提案してくれるLINE Botを作ってみた(LINE Messaging API)｜立花翔｜note](https://note.mu/stachibana/n/n77c3826a0d40)

[Messaging APIを使ったLINE Botでアイドル顔画像管理 - すぎゃーんメモ](http://memo.sugyan.com/entry/2016/10/14/182309)
機械学習の教師データ作成につかえる

# line bot
利点
気軽にスマホで通知
気軽に聞ける
PCの使えない場面で使える→移動中とか
webでググれば？の反論
→ 迅速かつ確実な情報取得 + 情報の簡単共有ルーム
→ 位置情報取得
→ 会話してる感

ボタンでyesno応えられるので、インタラクティブなアンケートに使える

結果返す → 良さげなの選択 → 選択結果から、さらにいい結果返す
お店とかレシピの絞り込み検索
カラオケ選曲

和食 中華 → 和食 → 肉 野菜 中間？ → 。。。
[ホットペッパー | APIリファレンス | リクルートWEBサービス](http://webservice.recruit.co.jp/hotpepper/reference.html#a1to)
[ぐるなび Web Service - ぐるなびWebサービス利用規約](http://api.gnavi.co.jp/api/agreement/)
[Documentation - Yelp Fusion](https://www.yelp.com/developers/documentation/v3)


適用事例
* 頻繁に使う
* 友達と一緒にやると面白くなる → 245クラウドとかハミガコ いま動画みてますとか
* スタンプ送ると？ → imageか？
* 広告につかえる

イベント管理bot
12/3 △とかでデータ更新する？


# ベンチ
Facebook Messenger Platform


# 2016/11/30

# ぐるなびAPIの登録

[ぐるなび Web Service - 新規アカウント発行 入力内容確認](https://ssl.gnavi.co.jp/api/regist/?p=conf)

## 利用ルール

データ更新について
ぐるなびWEBサービスが提供する飲食店データは随時最新の情報に更新されております。
データを利用してコンテンツを提供される場合はコンテンツデータを最新に更新していただきますようお願いします。

リンク表示

クレジット表示: lineのメッセージはhtmlに対応してないので、画像をはることにする。

<a href="http://www.gnavi.co.jp/">
<img src="http://apicache.gnavi.co.jp/image/rest/b/api_265_65.gif" width="265" height="65" border="0" alt="グルメ情報検索サイト　ぐるなび">
</a>

画像の掲載について
提供：ぐるなび」と明記してください

## 利用制限
とくに指定されていない。


## とれる仕様

仕様
基本的にGnaviから一気に候補をとってくる。(一度のリクエストで済ますため)
とってきたデータをキャッシュする。
キャッシュから絞り込み検索する。



gnavi必要な仕様
keyid ○ string アクセスキー ぐるなびより提供されたアクセスキー
format string レスポンス形式 xmlまたはjson(callback関数指定時にJSONP形式で出力)
latitude number 緯度 分秒十進式,
longitude number 経度 分秒十進式,
range integer 範囲 緯度/経度からの検索範囲(半径) 1:300m、2:500m、3:1000m、4:2000m、5:3000m （デフォルト:500m）
sort integer ソート順 レスポンスデータのソート順,指定なし：ぐるなびソート順 1:店舗名、2:業態
hit_per_page integer ヒット件数 一度リクエストで得るレスポンスデータの最大件数（デフォルト:10）
freeword string フリーワード検索 検索ワードをUTF-8でURLエンコードすること「,」区切りで複数ワードが検索可能（１０個まで）

検索仕様

* user_idごとに検索結果を保持。一定時間(15m)で消去
* lat longで位置から検索
* range デフォルトで検索 → 近い、遠いコマンドで再検索
* hit_per_pageは100件とする


インタラクティブ検索仕様

現在位置から検索 → 結果を適当にまとめる
→ 文字列で絞込 → 候補となるものを3つ提示

候補は以下ルールで選択

* Time.current.weekday が休業日でない (opentimeやholiday)
* 平均予算 → Time.currentから昼夜判定。 結果から平均にちかいものから提示
* ジャンル → ジャンルは1ジャンル1点。

結果カード仕様
* 画像URL image_url, shop_image1
* text:
  * 店名 name
  * ジャンル category_name_s, category, category_name_l
  * 予算 budget  , party, lunch
  * 距離 range
* 電話番号 tel → iosで起動
* もっと見る url
* ここにする → googlemap表示 http://r.gnavi.co.jp/g183519/map/,
             [Google マップ URL スキーム  |  Google Maps SDK for iOS  |  Google Developers](https://developers.google.com/maps/documentation/ios-sdk/urlscheme?hl=ja)


応答仕様

さっき, 直前結果
もっと, 別の検索結果
別,別の検索結果

安い/高い
近い/遠い
[ジャンル名]



