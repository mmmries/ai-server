require 'json'

module AIS
  ## The Host object acts as a host for each connected client
  ## All import client related information is stored here
  ## It is implemented using the state machine pattern
  class Host
    def initialize(client)
      @client = client
      @state = :init
      
      client.onopen { open }
      client.onclose { close }
      client.onmessage { |msg| receive(msg) }
    end
    
    # start the dialog with the client
    def open
      @client.send JSON.generate({:type => :greeting})
    end
    
    # receive a message from the client
    def receive(msg)
      begin
        msg = JSON.parse!(msg)
        @client.send JSON.generate({:type => :ack})
      rescue
        #puts $! #TODO make this into a logger statement
        @client.send JSON.generate({:type => :error, :message => $!.to_s})
      end
    end
    
    # end the dialog with this client
    def close
      #cleanup all related objects
    end
  end
end