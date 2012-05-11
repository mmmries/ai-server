require 'rubygems'
require 'rspec'
require 'eventmachine'
require 'em-spec/rspec'

$LOAD_PATH.unshift File.expand_path("lib")

RSpec.configure do |config|
  config.mock_with :rspec
end

def create_server
  AIS::Server.new(:host => '127.0.0.1', :port => 12345)
end

def create_client
  c = EventMachine::HttpRequest.new('ws://127.0.0.1:12345/').get :timeout => 1.0 
  c.errback{ fail 'client request failed' }
  c
end