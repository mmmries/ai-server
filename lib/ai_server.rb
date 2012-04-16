require 'eventmachine'
require 'em-websocket'

class AIServer
  attr_reader :host, :port
  def initialize(opts)
    @host = opts[:host] || '0.0.0.0'
    @port = opts[:port] || 8080
  end
  
  def start
    EM.run do
      #puts "Starting AIServer on #{@host}:#{@port}"
      EventMachine::WebSocket.start(:host => @host, :port => @port) do |ws|
        ws.onopen do
          #puts "opened ws connection"
          ws.send "HELLO"
        end
        
        ws.onclose do
          #puts "closed connection"
        end
        
        ws.onmessage do |msg|
          #puts "received #{msg}"
          ws.send "echo: #{msg}"
        end
      end
    end
  end
end