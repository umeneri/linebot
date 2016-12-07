require 'sinatra'
require 'sinatra/reloader'
require 'logger'
require 'line/bot'
require './gnavi_bot'

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

get '/gnavi' do
  logger.info 'rest_buttons'
  # json = JSON.pretty_generate(gnavi_bot.rest_buttons).gsub(/\n/, '<br>')
  # logger.info json
  #
  # json

  'gnavi'
end

get '/thumbnail.png' do
  content_type :png
  send_file "thumbnail.png"
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

        gnavi_bot(latitude: event.message['latitude'],
                  longitude: event.message['longitude'],
                  category: 'カレー',
                  range: 2,
                 )
        gnavi_bot.search
        gnavi_bot.select_candidate_by_category
        ap gnavi_bot.store.cands
        message = gnavi_bot.rest_carousel

        ap message
        p client.reply_message(event['replyToken'], message).inspect
      end
    when Line::Bot::Event::Postback
        p 'postback'
        ap event

        category_name_l = event['postback']['data']
        gnavi_bot.select_candidate_in_category(category_name_l)
        ap gnavi_bot.store.cands
        message = gnavi_bot.rest_carousel

        p client.reply_message(event['replyToken'], message).inspect
    end
  }

  "OK"
end
