require 'eventmachine'
require 'em-websocket'
require 'ais/host'

module AIS
  class Server
    attr_reader :host, :port
    def initialize(opts = {})
      @host = opts[:host] || '0.0.0.0'
      @port = opts[:port] || 8080
    end

    def start
      #puts "Starting AIServer on #{@host}:#{@port}"
      EventMachine::WebSocket.start(:host => @host, :port => @port) do |ws|
        host = AIS::Host.new(ws, self)
      end
    end
    
    def start_game(game_type)
      AIS::Game::Test.new
    end
  end
end