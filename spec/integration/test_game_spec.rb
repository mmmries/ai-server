require 'helper'
require 'em-http-request'
require 'ai_server'

describe AIS::Game::Test do
  include EM::SpecHelper
  default_timeout 1.0
  
  let(:ais){ AIS::Server.new(:host => "0.0.0.0", :port => 12345 ) }
  let(:client) { 
    c = EventMachine::HttpRequest.new('ws://127.0.0.1:12345/').get :timeout => 1.0 
    c.errback{ fail }
    c
  }
  
  it "should generate ai players for games" do
    em do
      ais.start
      client.stream do |msg|
        msg = JSON.parse!(msg)
        p msg
        ["greeting","created","created_ai"].should include(msg["type"])
        client.send JSON.generate( :type => :create, :game => :test ) if msg["type"] == "greeting"
        client.send JSON.generate( :type => :create_ai ) if msg["type"] == "created"
        done if msg["type"] == "created_ai"
      end
    end
  end
  
  it "should request a move from the client"
  
  it "should accept a move from the client"
  
  it "should report the end of the game to the client"
  
end