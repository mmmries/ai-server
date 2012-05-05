require 'helper'
require 'em-http-request'
require 'ai_server'

describe AIS::Server do
  include EM::SpecHelper
  default_timeout 1.0
  
  let(:ais){ AIS::Server.new(:host => "0.0.0.0", :port => 12345 ) }
  let(:client) { 
    c = EventMachine::HttpRequest.new('ws://127.0.0.1:12345/').get :timeout => 1.0 
    c.errback{ fail }
    c
  }
  
  it "should accept websocket connections" do
    EM.run do
      ais.start 
      EM.add_timer(0.1) do
        client.stream do |msg|
          client.response_header.status.should == 101
          client.close_connection
          EM.stop
        end
      end
    end
  end
  
  it "should greet new connections" do
    EM.run do
      ais.start
      EM.add_timer(0.1) do
        client.stream do |msg|
          msg = JSON.parse!(msg)
          msg["type"].should == "greeting"
          EM.stop
        end
      end
    end
  end
  
  it "should accept game creation requests" do
    EM.run do
      ais.start
      EM.add_timer(0.1) do
        client.stream do |msg|
          msg = JSON.parse!(msg)
          ["greeting","game_created"].should include(msg["type"])
          client.send JSON.generate({:type => :registration, :game => :test}) if msg["type"] == "greeting"
          EM.stop if msg["type"] == "game_created"
        end
      end
    end
  end
  
  it "should respond with an error to non-json strings" do
    EM.run do
      ais.start
      EM.add_timer(0.1) do
        client.stream do |msg|
          msg = JSON.parse!(msg)
          ["greeting","error"].index(msg["type"]).should_not be_nil
          client.send("hoorah!") if msg["type"] == "greeting"
          EM.stop if msg["type"] == "error"
        end
      end
    end
  end
  
  it "should accept registrations for games"
  it "should generate ai players for games"
  it "should request a move from the client"
  it "should accept a move from the client"
  it "should report the end of the game to the client"
end