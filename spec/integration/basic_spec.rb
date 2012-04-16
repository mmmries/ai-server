require 'helper'
require 'em-http-request'
require 'ai_server'

describe AIServer do
  include EM::SpecHelper
  default_timeout 1
  
  it "should not accept non-websocket connections accept websocket connections" do
    em {
      s = AIServer.new(:host => "0.0.0.0", :port => 12345 )
      s.start
      EventMachine.add_timer(0.1) do
        http = EventMachine::HttpRequest.new('ws://127.0.0.1:12345').get :timeout => 1.0
        http.errback { fail }
        http.callback {
          http.response_header.status.should == 101
          http.close_connection
          EM.stop
        }
        http.stream{|msg| puts "client received: #{msg}" }
      end
    }
  end
  
  it "should accept websocket connections"
  it "should greet new connections"
  it "should accept game requests"
  it "should accept registrations for games"
end