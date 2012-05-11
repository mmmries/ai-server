module AIS
  module Game
    ## A simple implementation of the TicTacToe game
    ## Requires 2 players
    ## The game state is represented by an array of 9 characters.
    ## The characters represent the spaces on the board from left->right, top->bottom
    ## an X character
    class TicTacToe
      attr_reader :current_mark, :state
      def initialize
        @players = []
        @current_mark = 'X'
        @state = 1.upto(9).map{ '' } #the spaces on the board listed left->right, top->bottom
      end
      
      def add_client(client)
        raise 'TicTacToe only supports 2 players' if @players.size >= 2
        @players << client if @players.size < 2
        request_move if @players.size == 2
      end
      
      def current_player
        @players.first
      end
      
      def change_turn
        current = @players.shift
        @players.push(current)
        @current_mark = (@current_mark == 'X') ? 'O' : 'X'
      end
      
      def request_move
        current_player.send JSON.generate(:type => :move_request, :state => state, :your_mark => current_mark)
      end
    end 
  end
end