require 'helper'
require 'em-http-request'
require 'ai_server'

describe AIS::Game::Test do
  include EM::SpecHelper
  default_timeout 1.0
  
  let(:ais){ create_server }
  let(:client) { create_client }
  
  it "should request a move from the client and echo all client messages" do
    em do
      ais.start
      client.stream do |msg|
        msg = JSON.parse!(msg)
        ["greeting","created","move_request","echo"].should include(msg["type"])
        client.send JSON.generate(:type => :create, :game => :test) if msg["type"] == "greeting"
        client.send JSON.generate(:type => :move, :seed => :move) if msg["type"] == "created"
        done if msg["type"] == "echo" && msg["seed"] = "move"
      end
    end
  end
end