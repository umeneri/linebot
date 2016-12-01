require 'sinatra'
require 'sinatra/reloader'
require 'logger'
require 'line/bot'
require './gnavi_search'

logger = Logger.new('sinatra.log')

get '/' do
  'hello'
end

get '/ls' do
  ls = `ls`
  p ls
end
get '/path/to' do
  "this is [/path/to]"
end

get '/hello/*' do |name|
  "hello #{name}. how are you?"
end

get '/erb_template_page' do
  erb :erb_template_page
end


def rest_buttons(latitude: 35.670083, longitude: 139.763267)
  # rests = GnaviClient.search_with_present_location(
  #   latitude: latitude,
  #   longitude: longitude,
  #   range: 2,
  #   hit: 5,
  #   word: '寿司',
  # )

  rests = search_with_present_location(
    latitude: 35.670083,
    longitude: 139.763267,
    word: '寿司'
  )

  build_rest_buttons(rests[0])
end


get '/gnavi' do
  logger.info 'rest_buttons'

  json = JSON.pretty_generate(rest_buttons).gsub(/\n/, '<br>')
  logger.info json

  json.gsub(/\n/, '<br>')
end


def client
  @client ||= Line::Bot::Client.new { |config|
    config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
    config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
  }
end

get '/line' do
  p client.reply_message('111', {type: 'text', text: 'test'}).inspect
end

post '/callback' do
  p 'callback'
  body = request.body.read

  signature = request.env['HTTP_X_LINE_SIGNATURE']
  unless client.validate_signature(body, signature)
    error 400 do 'Bad Request' end
  end

  p 'parse'
  events = client.parse_events_from(body)
  events.each { |event|
    case event
    when Line::Bot::Event::Message
      case event.type
      when Line::Bot::Event::MessageType::Text
        p 'text'
        message = {
          type: 'text',
          text: event.message['text']
        }
        p client.reply_message(event['replyToken'], message).inspect
      when Line::Bot::Event::MessageType::Image, Line::Bot::Event::MessageType::Video
        p 'content'
        response = client.get_message_content(event.message['id'])
        tf = Tempfile.open("content")
        tf.write(response.body)
      when Line::Bot::Event::MessageType::Location
        p event.message['id']
        p event.message['address']
        p event.message['latitude']
        p event.message['longitude']

        message = rest_buttons(latitude: event.message['latitude'],
                               longitude: event.message['longitude'])

        p message
        p client.reply_message(event['replyToken'], message).inspect
      end
    end
  }

  "OK"
end
