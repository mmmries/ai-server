require 'json'
require 'ais/game/test'

module AIS
  ## The Host object acts as a host for each connected client
  ## All import client related information is stored here
  ## It is implemented using the state machine pattern.  The states are:
  ## => :init         this client has just connected and is pending any decision
  ## => :hosting      this client is hosting a game
  ## => :joined       this client has joined a game
  ## => 
  class Host
    def initialize(client, server)
      @client = client
      @server = server
      @state = :init
      @game = nil
      
      client.onopen { open }
      client.onclose { close }
      client.onmessage { |msg| receive(msg) }
    end
    
    # start the dialog with the client
    def open
      @client.send JSON.generate({:type => :greeting})
    end
    
    # end the dialog with this client
    def close
      # TODO cleanup all related objects (ie games)
    end
    
    # receive a message from the client
    def receive(msg)
      begin
        msg = JSON.parse!(msg)
        @game.receive(msg, @client) unless @game.nil?  || msg["type"] == "quit"
        self.send("#{@state}_#{msg['type']}".to_sym, msg)
      rescue
        #puts $! #TODO make this into a logger statement
        @client.send JSON.generate({:type => :error, :message => $!.to_s})
      end
    end
    
    def init_create(msg)
      @state = :hosting
      @game = AIS::Game::Test.new
      @game.add_client(@client)
      @server.add_game(@game)
      
      @client.send JSON.generate({:type => :created, :game_id => @game.object_id})
    end
    
    def init_join(msg)
      @client.send JSON.generate({:type => :joined})
      @game = @server.games.find{ |g| g.object_id == msg["game_id"] }
      raise "Failed to find game #{msg['game_id']}" if @game.nil?
      @game.add_client(@client)
      @state = :joined
    end
    
    def hosting_quit(msg)
      #TODO
      raise '#hosting_quit not implemented yet, should quit the current game and clean it up'
    end
    
    def joined_quit(msg)
      #TODO
      raise '#joined_quit not implemented yet, should quit the current game'
    end
  end
end