module AIS
  module Game
    class Test
      def init
        @state = :init
        @turn = nil
      end
      
      def add_client(client)
        @clients << client
      end
    end
  end
end