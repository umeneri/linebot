require 'json'
require 'rest-client'
require 'pp'

class GnaviClient
  BASE_URL = 'http://api.gnavi.co.jp/RestSearchAPI/20150630/'
  API_KEY = 'bc9275da9a6984b8515426c4d01835a3'

  class << self
    def search_with_present_location(latitude: _latitude,
                                   longitude: _longitude,
                                   range: _range, hit: _hit, word: _word)
      params = {
        latitude:  latitude,
        longitude: longitude,
        range:     range,
        hit_per_page: hit,
      }

      params[:freeword] = word if word

      get_restaurants(params)
    end

    def get_restaurants(query)
      params = {
        keyid:     API_KEY,
        format:    'json',
        sort:      2,
      }
      get_restaurants_rest(params.merge(query))
    end

    def get_restaurants_rest(params)
      response =  RestClient.get(BASE_URL + '?', params: params)
      # pp response.headers
      # pp response.code

      if response.code == 200
        json = JSON.parse(response.body).dig('rest')
      else
        return nil
      end

      # pp json
      json
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
  end
end
