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
  
  let(:client2) {
    c = EventMachine::HttpRequest.new('ws://127.0.0.1:12345/').get :timeout => 1.0 
    c.errback{ fail }
    c
  }
  
  it "should accept websocket connections" do
    em do
      ais.start 
      EM.add_timer(0.1) do
        client.stream do |msg|
          client.response_header.status.should == 101
          client.close_connection
          done
        end
      end
    end
  end
  
  it "should greet new connections" do
    em do
      ais.start
      EM.add_timer(0.1) do
        client.stream do |msg|
          msg = JSON.parse!(msg)
          msg["type"].should == "greeting"
          done
        end
      end
    end
  end
  
  it "should accept game creation requests" do
    em do
      ais.start
      EM.add_timer(0.1) do
        client.stream do |msg|
          msg = JSON.parse!(msg)
          ["greeting","created", "move_request"].should include(msg["type"])
          client.send JSON.generate({:type => :create, :game => :test}) if msg["type"] == "greeting"
          done if msg["type"] == "created"
        end
      end
    end
  end
  
  it "should respond with an error to non-json strings" do
    em do
      ais.start
      EM.add_timer(0.1) do
        client.stream do |msg|
          msg = JSON.parse!(msg)
          ["greeting","error"].index(msg["type"]).should_not be_nil
          client.send("hoorah!") if msg["type"] == "greeting"
          done if msg["type"] == "error"
        end
      end
    end
  end
  
  it "should accept registrations for games" do
    em do
      ais.start
      EM.add_timer(0.1) do
        client.stream do |msg|
          msg = JSON.parse!(msg)
          ["greeting","created","move_request"].should include(msg["type"])
          client.send JSON.generate({:type => :create, :game => :test}) if msg["type"] == "greeting"
          if msg["type"] == "created" then
            client2.stream do |msg_guest|
              msg_guest = JSON.parse!(msg_guest)
              ["greeting","joined","move_request"].should include(msg_guest["type"])
              client2.send JSON.generate(:type => :join, :game_id => msg["game_id"]) if msg_guest["type"] == "greeting"
              done if msg_guest["type"] == "joined"
            end
          end
        end
      end
    end
  end
end