module AIS
  module Game
    ## A test game class.  Only requires 1 player and just sends a request for a move and then echoes back all future messages
    class Test
      def initialize
        @clients = []
      end
      
      def add_client(client)
        @clients << client
        client.send JSON.generate(:type => :move_request)
      end
      
      def receive(msg, client)
        msg["type"] = "echo"
        client.send JSON.generate(msg)
      end
    end
  end
end