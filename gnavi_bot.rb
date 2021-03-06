require './gnavi_store'

class Event
  attr_reader :message

  def initialize(params)
    @message = params
  end
end


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

  # store restaulant
  # @return restaulant
  def search
    @store.search_with_present_location
  end

  # @return candidate
  def select_candidate_by_category
    @store.group_candidate('category_name_l')
  end

  # @return candidate
  def select_candidate_in_category(category_name_l)
    @store.select_candidate_in_category(category_name_l)
  end

  def rest_button
    build_button(@store.rests[0])
  end

  def rest_carousel
    build_carousel(@store.cands) if @store.cands
  end

  # View

  def build_rest_detail(rest)
    "#{rest['category_name_l']}/#{rest['category_name_s']}/#{rest['category']}, #{rest['budget']}, #{rest['lunch']}, #{rest['party']}"
  end

  def to_https(url)
    if url.class == String
      url.gsub(/https?/, 'https')
    else
      "https://curry-linebot.herokuapp.com/thumbnail.png"
    end
  end

  def map_url(latitude, longitude)
    "https://www.google.com/maps/preview/@#{"%.7f" % latitude},#{"%.7f" % longitude},15z"
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
  def build_button(rest)
    map_action = {
      "type": "uri",
      "label": "地図を見る",
      "uri": map_url(rest['latitude'], rest['longitude'])
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
      "data": "#{rest['category']}"
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
        thumbnailImageUrl: image_url,
        actions: actions,
      }
    }


    message
  end

  def build_column(rest)
    # map_action = {
    #   "type": "uri",
    #   "label": "地図を見る",
    #   "uri": map_url(rest['latitude'], rest['longitude'])
    # }

    params = {
      'action': 'location',
      'id': rest['id'],
      'latitude': @latitude,
      'longitude': @longitude,
    }

    loc_action = {
      "type": "postback",
      "label": "位置を見る",
      "data": url_encode(params),
    }

    url_action = {
      "type": "uri",
      "label": "もっと見る",
      "uri": rest['url']
    }

    params = {
      'action': 'category',
      'id': rest['id'],
      'latitude': @latitude,
      'longitude': @longitude,
    }

    category_action = {
      "type": "postback",
      "label": "同じジャンル",
      "data": url_encode(params),
    }

    p params

    image_url = to_https(rest['image_url'])
    title = "#{ rest['name']} #{rest['name_kana']}"[0..39]
    text = build_rest_detail(rest)[0..60]
    # actions = [map_action, url_action, category_action].first(3)
    actions = [loc_action, url_action, category_action].first(3)

    message = {
      title: title,
      text: text,
      actions: actions,
      thumbnailImageUrl: image_url
    }


    message
  end

  def build_location(rest)
    {
      "type": "location",
      "title": "#{ rest['name']} #{rest['name_kana']}"[0..39],
      "address": rest['address'],
      "latitude": "%.7f" % rest['latitude'].to_f,
      "longitude": "%.7f" % rest['longitude'].to_f,
    }
  end

  # columns: 最大5個
  def build_carousel(rests=@store.cands)
    columns = rests.first(5).map {|rest| build_column(rest) }

    {
      type: "template",
      altText: "this is a carousel template",
      template: {
        type: "carousel",
        columns:  columns,
      }
    }
  end

  def url_encode(enum)
    URI::encode_www_form(enum)
  end

  def url_decode(data)
    q = URI::parse("?" + data).query
    URI::decode_www_form(q)
  end

  def url_test
    cat = 'カレー'
    hash = {
      action: 'category',
      category: cat,
    }

    p uri = url_encode(hash)

    p url_decode(uri)
  end

  def credit_message
    {
      type: 'text',
      text: 'Powered by ぐるなび'
    }
  end

  def result_message(size)
    {
      type: 'text',
      text: "#{size}件見つかりました"
    }
  end

  def messages_with_location(event)
    update(latitude: event.message['latitude'],
           longitude: event.message['longitude'],
           category: 'カレー',
           # category: '',
           range: 3,
          )

    p @latitude
    p @longitude

    search
    select_candidate_by_category
    @store.cands


    carousel_message = rest_carousel

    [result_message(@store.cands.size), carousel_message, credit_message]
  end

  def messages_with_postback(event)
    ap url_decode(event['postback']['data'])

    params = Hash[url_decode(event['postback']['data'])]

    pp params

    update(latitude: params['latitude'],
           longitude: params['longitude'],
           category: 'カレー',
           # category: '',
           range: 3,
          )


    # action
    case params['action']
    when 'category'
      p params

      search
      select_candidate_by_category

      unless @store.rests
        result_message = {
          type: 'text',
          text: "エラーが発生しました。候補がありません"
        }

        return messages = [result_message]
      end

      rest = @store.rests.find do |_rest|
        _rest['id'] == params['id']
      end

      unless rest
        result_message = {
          type: 'text',
          text: "エラーが発生しました。idに該当するものが見つかりません"
        }

        return messages = [result_message]
      end

      pp rest

      select_candidate_in_category(rest['category_name_l'])
      ap @store.cands

      carousel_message = rest_carousel

      return messages = [result_message(@store.cands.size), carousel_message, credit_message]

    when 'location'
      rest = @store.rests.find do |_rest|
        _rest['id'] == params['id']
      end

      p rest

      if rest
        loc_message = build_location(rest)

        result_message = {
          type: 'text',
          text: "お店の位置です。クリックすると地図が出ます"
        }

        messages = [result_message, loc_message]

      else
        result_message = {
          type: 'text',
          text: "エラーが発生しました"
        }

        messages = [result_message]
      end
    end

    return  messages
  end
end



def test
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
  #   latitude:  35.708467,
  #   longitude: 139.710944,
  #   # latitude: 35.670083,
  #   # longitude: 139.763267,
  #   category: 'カレー',
  #   # word: 'カレー',
  # )

  event = Event.new(
    {
      'latitude' => 35.708467,
      'longitude' => 139.710944,
      'postback' => {
        'data' =>  'action=category&id=g501133'
      }
    }
  )

  # ap event.message
  ap gnavi_bot.messages_with_location(event)
  ap gnavi_bot.messages_with_postback(event)

  # p gnavi_bot.map_url(35.69855853730646, 139.72420290112495)

  #
  # gnavi_bot.search
  # ap gnavi_bot.store.rests.count
  # ap gnavi_bot.select_candidate_in_category('カレー')
  # ap gnavi_bot.store.cands
  # ap gnavi_bot.rest_carousel
end
#
# test
#
