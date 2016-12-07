require 'json'
require 'holiday_jp'
require "awesome_print"
require './gnavi_client'
require 'active_support/time'

# Store
# 候補が開店しているか
# 候補の距離を計算
# 候補を距離順に並べ替え
# 候補の金額を計算
# 候補をカテゴリでgroup_by

# データストアから最初の候補を選択
# データストアから前候補を除外した候補を選択 (次の、別の)
# データストアから前候補より安いor高い候補を選択
# データストアから前候補より近いor遠い候補を選択
# データストアからジャンルを指定して候補を選択
# データストアからフリーワードを指定して検索


class GnaviStore
  attr_reader :rests, :cands

  # attr: latitude, longitude, word, category, rest
  def initialize(options = {})
    options.each do |key, value|
      instance_variable_set("@#{key}", value)
    end
    yield(self) if block_given?
  end

  def update(options = {})
    options.each do |key, value|
      instance_variable_set("@#{key}", value)
    end

    yield(self) if block_given?
  end

  # @return : [hash]
  def search_with_present_location
    # rests = JSON.load(File.read('test.json')).dig('rest')
    @rests = GnaviClient.search_with_present_location(
      latitude: @latitude,
      longitude: @longitude,
      range: 2,
      hit_per_page: 100,
      # word: @word,
      category_l: @category,
    )

    flat_hash
    filter_rests
  end

  def flat_hash()
    filter = %w(id name name_kana latitude longitude category url url_mobile
  address tel opentime holiday budget party lunch)

    @rests = @rests.map! do |rest|
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

    @rests
  end

  # @param holiday String
  def opening?(today, holiday)
    # today = Time.new
    # puts holiday, today

    if holiday.nil? || holiday == {}
      true
    elsif holiday =~ /祝/ && HolidayJp.holiday?(today.to_date)
      false
    elsif holiday =~ /^(無|年中無休|不定休日|24時間)/
      true
    elsif holiday =~ /^(日曜日)/ || today.wday == 0
      false
    else
      %w(月 火 水 木 金 土).each_with_index do |w, i|
        return !(holiday.include?(w) && today.wday == i + 1)
      end
    end
  end

  def self.test_opening
    today = Date.new(2016, 12, 23)
    holiday = '毎週月曜日 祝日'
    p 'f', opening?(today, holiday)

    holiday = '毎週月曜日'
    today = Date.new(2016 ,12 ,19)
    p 'f', opening?(today, holiday)

    holiday = '毎週月・火曜日<BR>年末年始（2016年12月30日～2017年1月3日）'
    today = Date.new(2016 ,12 ,19)
    p 'f', opening?(today, holiday)

    today = Date.new(2016 ,12 ,19)
    p 'f', opening?(today, holiday)

    holiday = '年中無休<BR>年末年始（2016年12月31日～2017年1月4日）'
    p 't', opening?(today, holiday)
  end

  def set_amount(rest)
    current = Time.new.hour
    lunch_start = 11
    dinner_start = 15
    if rest['lunch'] != {} && current > lunch_start && current < dinner_start
      rest['amount'] = rest['lunch']
    elsif rest['party'] != {} && current > dinner_start
      rest['amount'] = rest['party']
    elsif rest['budget'] != {}
      rest['amount'] = rest['budget']
    else
      rest['amount'] = 10000000000
    end
  end

  def distance(rest, latitude, longitude)
    (rest['latitude'].to_i - latitude.to_i) * 2 + (rest['longitude'].to_i - longitude.to_i) * 2
  end

  def set_distance(rest)
    rest['distance'] = distance(rest, @latitude, @longitude)
  end

  def filter_rests
    p 'rest count', @rests.size

    @rests = @rests.select do |rest|
      # tempolary
      opening?(Time.new(2016, 12, 7, 11), rest['holiday']) && set_amount(rest)
    end

    p 'cand count', @rests.size

    @rests
  end

  def select_candidate_by_name(keys, name)
    p 'rest count', @rests.size

    if keys.class != Array
      keys = [keys]
    end

    @cands = @rests.select do |rest|
      keys.select do |key|
        rest[key].include?(name) if rest[key]
      end != []
    end

    p 'cand count', @cands.size

    @cands
  end

  def group_candidate(key)
    cand_groups = @rests.group_by do |rest|
      rest[key]
    end

    @cands = cand_groups.map do |k, v|
      p 'group', k
      # ap v
      filter_in_group_with_amount(v)
    end
  end

  def filter_in_group_with_amount(group, opt = {})
    group.min_by do |rest|
      rest['amount'].to_i
    end
  end

  def filter_in_group_with_distance(group, opt = {})
    group.min_by do |rest|
      rest['distance'].to_i
    end
  end
end

# GnaviStore.test_opening

# gs = GnaviStore.new(
#   longitude: 139.763267,
#   latitude: 35.670083,
#   category: 'カレー',
#   # word: 'カレー',
# )

# gs.search_with_present_location
# gs.filter_rests
# # pp '++++++++++++++++++++++++++++++'
# # ap gs.group_candidate('category_name_l')
# pp '++++++++++++++++++++++++++++++'
# ap gs.select_candidate_by_name(['category', 'pr', 'category_name_l'], 'カレー')

# rests = gs.search_with_present_location.map do |rest|
#   rest.select do |k, v|
#     %w(holiday opentime budget party lunch).include? k
#   end
# end

# rests.each do |rest|
#   GnaviStore.opening?(rest)
# end
# ap rests
