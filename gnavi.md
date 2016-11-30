
# 仕様
最大件数は500件 (試した)


# request
keyid, ○, string, アクセスキー, ぐるなびより提供されたアクセスキー
id, string, 店舗ID, 「,」区切りで店舗IDを複数検索可能（１０個まで）
format, string, レスポンス形式, xmlまたはjson(callback関数指定時にJSONP形式で出力)
callback, string, コールバック関数, formatが「json」の場合のみ
name, string, 店舗名, UTF-8でURLエンコードすること
name_kana, string, 店舗名読み, カタカナで指定,
UTF-8でURLエンコードすること
tel, string, 電話番号, ハイフン必須
address, string, 住所, （都道府県＋市町村＋番地）の文字列をUTF-8でURLエンコードすること
area, string, 地方コード, コードはエリアマスタ取得APIより取得
pref, string, 都道府県コード, コードは都道府県マスタ取得APIより取得
areacode_l, string, エリアLコード, コードはエリアLマスタ取得APIより取得,
areacode_m, string, エリアMコード, コードはエリアMマスタ取得APIより取得,
areacode_s, string, エリアSコード, コードはエリアSマスタ取得APIより取得,
category_l, string, 大業態コード, コードは大業態マスタ取得APIより取得,
category_s, string, 小業態コード, コードは小業態マスタ取得APIより取得,
input_coordinates_mode, integer, 入力測地系タイプ, 入力する緯度/経度の測地系のタイプを指定,
1:日本測地系、,
2:世界測地系（デフォルト:日本測地系）
equipment, string, 設備・サービス, 設備・サービスの文字列をUTF-8で,
URLエンコードすること
※2015年8月末に提供を終了しました
coordinates_mode, integer, 測地系タイプ, レスポンスに含まれる緯度/経度の測地系を指定,
1:日本測地系、2:世界測地系（デフォルト:日本測地系）
latitude, number, 緯度, 分秒十進式,
input_coordinates_mode(入力測地系タイプ）の選択したタイプの値で指定
longitude, number, 経度, 分秒十進式,
input_coordinates_mode(入力測地系タイプ）の選択したタイプの値で指定
range, integer, 範囲, 緯度/経度からの検索範囲(半径),
1:300m、2:500m、3:1000m、4:2000m、5:3000m
（デフォルト:500m）
sort, integer, ソート順, レスポンスデータのソート順,
指定なし：ぐるなびソート順,
1:店舗名、2:業態
offset, integer, 検索開始位置, 検索開始レコードの位置（デフォルト:1）
hit_per_page, integer, ヒット件数, 一度リクエストで得るレスポンスデータの最大件数（デフォルト:10）
offset_page, integer, 検索開始ページ, 検索開始ページ位置（デフォルト:1）
freeword, string, フリーワード検索, 検索ワードをUTF-8でURLエンコードすること「,」区切りで複数ワードが検索可能（１０個まで）
freeword_condition, integer, フリーワード検索条件タイプ, フリーワード検索の条件を指定,
1:AND検索、2:OR検索（デフォルト:AND検索）
lunch, integer, ランチ営業あり, 0:絞込みなし(デフォルト)、1：絞込みあり
no_smoking, integer, 禁煙席あり, 0:絞込みなし(デフォルト)、1：絞込みあり
card, integer, カード利用可, 0:絞込みなし(デフォルト)、1：絞込みあり
mobilephone, integer, 携帯の電波が入る, 0:絞込みなし(デフォルト)、1：絞込みあり
bottomless_cup, integer, 飲み放題あり, 0:絞込みなし(デフォルト)、1：絞込みあり
sunday_open, integer, 日曜営業あり, 0:絞込みなし(デフォルト)、1：絞込みあり
takeout, integer, テイクアウトあり, 0:絞込みなし(デフォルト)、1：絞込みあり
private_room, integer, 個室あり, 0:絞込みなし(デフォルト)、1：絞込みあり
midnight, integer, 深夜営業あり, 0:絞込みなし(デフォルト)、1：絞込みあり
parking, integer, 駐車場あり, 0:絞込みなし(デフォルト)、1：絞込みあり
memorial_service, integer, 法事利用可, 0:絞込みなし(デフォルト)、1：絞込みあり
birthday_privilege, integer, 誕生日特典あり, 0:絞込みなし(デフォルト)、1：絞込みあり
betrothal_present, integer, 結納利用可, 0:絞込みなし(デフォルト)、1：絞込みあり
kids_menu, integer, キッズメニューあり, 0:絞込みなし(デフォルト)、1：絞込みあり
outret, integer, 電源あり, 0:絞込みなし(デフォルト)、1：絞込みあり
wifi, integer, wifiあり, 0:絞込みなし(デフォルト)、1：絞込みあり
microphone, integer, マイクあり, 0:絞込みなし(デフォルト)、1：絞込みあり
buffet, integer, 食べ放題あり, 0:絞込みなし(デフォルト)、1：絞込みあり
late_lunch, integer, 14時以降のランチあり, 0:絞込みなし(デフォルト)、1：絞込みあり
sports, integer, スポーツ観戦可, 0:絞込みなし(デフォルト)、1：絞込みあり
until_morning, integer, 朝まで営業あり, 0:絞込みなし(デフォルト)、1：絞込みあり
lunch_desert, integer, ランチデザートあり, 0:絞込みなし(デフォルト)、1：絞込みあり
projecter_screen, integer, プロジェクター・スクリーンあり, 0:絞込みなし(デフォルト)、1：絞込みあり
with_pet, integer, ペット同伴可, 0:絞込みなし(デフォルト)、1：絞込みあり
deliverly, integer, デリバリーあり, 0:絞込みなし(デフォルト)、1：絞込みあり
special_holiday_lunch, integer, 土日特別ランチあり, 0:絞込みなし(デフォルト)、1：絞込みあり
e_money, integer, 電子マネー利用可, 0:絞込みなし(デフォルト)、1：絞込みあり
caterling, integer, ケータリングあり, 0:絞込みなし(デフォルト)、1：絞込みあり
breakfast, integer, モーニング・朝ごはんあり, 0:絞込みなし(デフォルト)、1：絞込みあり
desert_buffet, integer, デザートビュッフェあり, 0:絞込みなし(デフォルト)、1：絞込みあり
lunch_buffet, integer, ランチビュッフェあり, 0:絞込みなし(デフォルト)、1：絞込みあり
bento, integer, お弁当あり, 0:絞込みなし(デフォルト)、1：絞込みあり
lunch_salad_buffet, integer, ランチサラダバーあり, 0:絞込みなし(デフォルト)、1：絞込みあり
darts, integer, ダーツあり, 0:絞込みなし(デフォルト)、1：絞込みあり


