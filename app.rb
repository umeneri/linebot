require 'sinatra'
require 'sinatra/reloader'
require 'line/bot'


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

def client
  @client ||= Line::Bot::Client.new { |config|
    config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
    config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
  }
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
        q = event.message
        p event.message['id']
        p event.message['text']
        p event.message['address']
        p event.message['latitude']
        p event.message['longitude']
        json = GNaviCrient.get_restaurant_json(q)
        cards = GNaviCrient.parse_to_card(json)
        # json
        message = build_carousel_massage(cards)
        p client.reply_message(event['replyToken'], message).inspect
      end
    end
  }

  "OK"
end
