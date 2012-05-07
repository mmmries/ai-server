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
      #cleanup all related objects
    end
    
    # receive a message from the client
    def receive(msg)
      begin
        msg = JSON.parse!(msg)
      
        self.send("#{@state}_#{msg['type']}".to_sym, msg)
      rescue
        #puts $! #TODO make this into a logger statement
        @client.send JSON.generate({:type => :error, :message => $!.to_s})
      end
    end
    
    
    def init_create(msg)
      @state = :hosting
      @client.send JSON.generate({:type => :created})
    end
    
    def init_join(msg)
      @state = :joined
      @client.send JSON.generate({:type => :joined})
    end
    
    # TODO hosting_quit
    # TODO joined_quit
    # TODO delegate all other hosting_* and joined_* messages to the game
  end
end