require 'json'
require 'rest-client'
require 'pp'

class GnaviClient
  API_KEY = 'bc9275da9a6984b8515426c4d01835a3'

  class << self
    def search_with_present_location(opt = {})
      params = opt
      params[:category_l] =  get_category_l(opt[:category_l]) || ""
      params[:freeword] = word if opt[:word]

      get_restaurants_rest(params)
    end

    def test
      query = {
        longitude: 139.763267,
        latitude: 35.670083,
        range: 2,
        hit: 10,
        word: 'カレー'
      }

      search_with_present_location(query)
    end

    def get_category_l(name)
      hash = get_category_name_l_rest
      out = hash.dig('category_l')&.select do |category|
        category['category_l_name'].include?(name)
      end&.first

      out['category_l_code'] if out
    end

    def get_category_s(name)
      hash = get_category_name_s_rest
      out = hash.dig('category_s')&.select do |category|
        category['category_s_name'].include?(name)
      end&.first

      out['category_s_code'] if out
    end

    private

    def get_category_name_l_rest
      url = 'http://api.gnavi.co.jp/master/CategoryLargeSearchAPI/20150630/'
      params = {
        keyid:     API_KEY,
        format:    'json',
      }
      get_hash(url, params)
    end

    def get_category_name_s_rest
      url = 'http://api.gnavi.co.jp/master/CategorySmallSearchAPI/20150630/'
      params = {
        keyid:     API_KEY,
        format:    'json',
      }
      get_hash(url, params)
    end

    def get_restaurants_rest(query)
      url = 'http://api.gnavi.co.jp/RestSearchAPI/20150630/'
      params = {
        keyid:     API_KEY,
        format:    'json',
        sort:      2,
      }
      get_hash(url, params.merge(query))&.dig('rest')
    end

    def get_hash(url, params)
      response =  RestClient.get(url + '?', params: params)
      # pp response.headers
      # pp response.code

      if response.code == 200
        # hash = JSON.parse(response.body).dig('rest')
        hash = JSON.parse(response.body)
      else
        return nil
      end

      # pp hash
      hash
    end
  end
end

# pp GnaviClient.get_category_l('カふぇかjfa')
