require 'helper'
require 'em-http-request'
require 'ai_server'

describe AIS::Game::Test do
  include EM::Spec
  default_timeout 1.0
  
  let(:ais){ AIS::Server.new(:host => "0.0.0.0", :port => 12345 ) }
  let(:client) { 
    c = EventMachine::HttpRequest.new('ws://127.0.0.1:12345/').get :timeout => 1.0 
    c.errback{ fail }
    c
  }
  
  it "should request a move from the client"
  
  it "should accept a move from the client"
  
  it "should report the end of the game to the client"
  
end