require 'eventmachine'
require 'em-websocket'
require 'ais/host'

module AIS
  class Server
    attr_reader :host, :port, :games
    def initialize(opts = {})
      @host = opts[:host] || '0.0.0.0'
      @port = opts[:port] || 8080
      @games = []
    end

    def start
      #puts "Starting AIServer on #{@host}:#{@port}"
      EventMachine::WebSocket.start(:host => @host, :port => @port) do |ws|
        host = AIS::Host.new(ws, self)
      end
    end
    
    def add_game(game)
      @games << game
    end
    
    def remove_game(game)
      @games = @games.select{|g| g.object_id != game.object_id }
    end
  end
end