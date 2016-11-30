require 'json'
require "awesome_print"


hash = JSON.load(File.read('test.json'))

ap hash.dig('rest')  rescue nil

