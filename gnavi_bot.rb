require './gnavi_store'

# Text
# イントロの説明
# 詳細な使い方説明
# 画像など未対応の場合の説明
# フリーワードを促す説明
# 位置情報を促す説明
# ヒット件数の説明
# 次の候補を促す説明

# View
# OS別に電話番号のアプリ起動リンク作成
# OS別にgoogle mapのアプリ起動リンク作成
# 距離を歩いてx分に変換
# URLをhttpsへ変換
# 候補のカルーセルを作成
class GnaviBot
  attr_reader :store

  def initialize(options = {})
    options.each do |key, value|
      instance_variable_set("@#{key}", value)
    end

    @store ||= GnaviStore.new(options)

    yield(self) if block_given?
  end

  def update(options = {})
    options.each do |key, value|
      instance_variable_set("@#{key}", value)
    end

    @store.update(options)

    yield(self) if block_given?
  end

  def build_rest_detail(rest)
    s = "#{rest['category_name_l']}/#{rest['category_name_s']}/#{rest['category']}, #{rest['budget']}, #{rest['lunch']}, #{rest['lunch']}"
    s
  end

  def to_https(url)
    if url.class == String
      url.gsub(/https?/, 'https')
    else
      nil
    end
  end

  def search
    @store.search_with_present_location
  end

  def select_candidate_by_category
    @store.group_candidate('category_name_l')
  end

  def rest_button
    build_button(@store.rests[0])
  end

  def rest_carousel
    build_carousel(@store.cands.first(5)) if @store.cands
  end

  # View
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
  def build_button(rest)
    map_action = {
      "type": "postback",
      "label": "地図を見る",
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

    message = {
      type: "template",
      altText: "this is a buttons template",
      template: {
        type: "buttons",
        title: title,
        text: text,
        actions: actions,
      }
    }

    message[:template][:thumbnailImageUrl] = image_url if image_url

    message
  end

  def build_column(rest)
    map_action = {
      "type": "postback",
      "label": "地図を見る",
      "data": "googlemaps://?center=#{rest['latitude']},#{rest['longitude']}&mapmode=streetview"
    }

    url_action = {
      "type": "uri",
      "label": "もっと見る",
      "uri": rest['url']
    }

    category_action = {
      "type": "postback",
      "label": "同じジャンル",
      "data": "action=category&category_name_l=#{rest['category_name_l']}"
    }

    image_url = to_https(rest['image_url'])
    title = "#{ rest['name']} #{rest['name_kana']}"
    text = build_rest_detail(rest)
    actions = [map_action, url_action, category_action]

    message = {
      title: title,
      text: text,
      actions: actions,
    }

    message[:thumbnailImageUrl] = image_url if image_url

    message
  end

  def build_carousel(rests=@store.cands)
    columns = rests.map {|rest| build_column(rest) }

    {
      type: "template",
      altText: "this is a carousel template",
      template: {
        type: "carousel",
        columns:  columns,
      }
    }
  end
end

def gnavi_bot(options = {})
  if @gnavi_bot.nil?
    @gnavi_bot = GnaviBot.new(options)
  elsif options == {}
    @gnavi_bot
  else
    @gnavi_bot.update(options)
  end
end

# gnavi_bot(
#   longitude: 139.72420290112495,
#   latitude:  35.69855853730646,
#   # longitude: 139.763267,
#   # latitude: 35.670083,
#   category: 'カレー',
#   # word: 'カレー',
# )
#
# gnavi_bot.search
# ap gnavi_bot.store.rests.count
# gnavi_bot.select_candidate_by_category
# ap gnavi_bot.store.cands
# ap gnavi_bot.rest_carousel
