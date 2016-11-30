require 'json'
require 'rest-client'
require 'pp'

class GnaviClient
  BASE_URL = 'http://api.gnavi.co.jp/RestSearchAPI/20150630/'
  API_KEY = 'bc9275da9a6984b8515426c4d01835a3'

  def self.get_restaurants(params)
    response =  RestClient.get(BASE_URL + '?', params: params)
    pp response.headers
    pp response.code
    json = JSON.parse(response.body)
    pp json
    File.write('test.json', response.body)
  end

  def self.parse_to_card()
  end

  def self.perform
    longitude = '139.763267'
    latitude  = '35.670083'
    range     = '1'
    hit_per_page = '10'

    query = {
      keyid:     API_KEY,
      format:    'json',
      latitude:  latitude,
      longitude: longitude,
      range:     range,
      hit_per_page: hit_per_page,
    }

    get_restaurants(query)
  end
end

GnaviClient.perform
