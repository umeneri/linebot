require 'json'
require "awesome_print"
require './gnavi_client'

def search_with_present_location(latitude: _latitude, longitude: _longitude, word: _word)
  # rests = JSON.load(File.read('test.json')).dig('rest')
  rests = GnaviClient.search_with_present_location(
    latitude: latitude,
    longitude: longitude,
    range: 2,
    hit: 5,
    word: word,
  )

  filter = %w(name name_kana latitude longitude category url url_mobile
  address tel opentime holiday budget party lunch)

  rests = rests.map! do |rest|
    dist = rest.select do |key, value|
      filter.include? key
    end

    dist['image_url'] = rest.dig('image_url', 'shop_image1')

    %w(line station station_exit walk).each do |key|
      dist[key] = rest.dig('access', key)
    end

    dist['pr'] = rest.dig('pr', 'pr_long')
    dist['category_name_l'] = rest.dig('code', 'category_name_l', 0)
    dist['category_name_s'] = rest.dig('code', 'category_name_s', 0)
    dist
  end

  rests
end

# thumbnailImageUrl  String  画像のURL (1000文字以内)
# HTTPS
# JPEGまたはPNG
# 縦横比 1:1.51
# 縦横最大1024px
# 最大1MB
# title  String  タイトル
# 40文字以内
# text  String  説明文
# 画像もタイトルも指定しない場合：160文字以内
# 画像またはタイトルを指定する場合：60文字以内
# actions  Array of Template Action  ボタン押下時のアクション
# 最大4個

def build_rest_detail(rest)
  s = "#{rest['category_name_l']}/#{rest['category_name_s']}/#{rest['category']}, #{rest['budget']}, #{rest['lunch']}, #{rest['lunch']}"
      s
end

def to_https(url)
  url.gsub(/https?/, 'https')
end

def build_rest_buttons(rest)
  map_action = {
    "type": "postback",
    "label": "ここにする",
    "data": "action=map&latitude=#{rest['latitude']}&longitude=#{rest['longitude']}"
  }

  tel_action = {
    "type": "postback",
    "label": "電話する",
    "data": "action=tel&tel=#{rest['tel']}"
  }

  url_action = {
    "type": "uri",
    "label": "もっと見る",
    "uri": rest['url']
  }

  category_action = {
    "type": "postback",
    "label": "同じジャンル",
    "data": "action=category&category=#{rest['category']}"
  }

  image_url = to_https(rest['image_url'])
  title = "#{ rest['name']} #{rest['name_kana']}"
  text = build_rest_detail(rest)
  actions = [map_action, tel_action, url_action, category_action]

  {
    type: "template",
    altText: "this is a buttons template",
    template: {
      type: "buttons",
      thumbnailImageUrl: image_url,
      title: title,
      text: text,
      actions: actions,
    }
  }
end

# rests = search_with_present_location(
#   longitude: 139.763267,
#   latitude: 35.670083,
# )
#
# ap rests[0]
# ap build_rest_buttons(rests[0])
#
