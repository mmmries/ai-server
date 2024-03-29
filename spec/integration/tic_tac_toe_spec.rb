require 'helper'
require 'em-http-request'
require 'ai_server'

describe AIS::Game::TicTacToe do
  include EM::SpecHelper
  default_timeout 1.0
  
  it "should accept 2 and only 2 clients" do
    em do
      ais = create_server
      ais.start
      
      c1 = create_client
      c2 = create_client
      c3 = create_client
      
      @game_id = 0
      
      c1.stream do |msg|
        msg = JSON.parse!(msg)
        ["greeting","created","move_request"].should include(msg["type"])
        c1.send JSON.generate(:type => :create, :game => "tic-tac-toe") if msg["type"] == "greeting"
        @game_id = msg["game_id"] if msg["type"] == "created"
        c2.send JSON.generate(:type => :join, :game_id => @game_id) if msg["type"] == "created"
        msg["your_mark"].should == "X" if msg["type"] == "move_request"
      end
      
      c2.stream do |msg|
        msg = JSON.parse!(msg)
        ["greeting","joined"].should include(msg["type"])
        c3.send JSON.generate(:type => :join, :game_id => @game_id) if msg["type"] == "joined"
      end
      
      c3.stream do |msg|
        msg = JSON.parse!(msg)
        ["greeting","error"].should include(msg["type"])
        done if msg["type"] == "error"
      end
    end
  end
  
  it "should request moves in alternating fashion" do
    em do
      ais = create_server
      ais.start
      
      c1 = create_client
      c2 = create_client
      
      move_number = 0
      
      c1.stream do |msg|
        msg = JSON.parse! msg
        c1.send JSON.generate(:type => :create, :game => "tic-tac-toe") if msg["type"] == "greeting"
        c2.send JSON.generate(:type => :join, :game_id => msg["game_id"]) if msg["type"] == "created"
        if msg["type"] == "move_request" then
          move_number += 1
          msg["your_mark"].should == "X"
          c1.send JSON.generate(:type => :move, :location => 0 ) if move_number == 1
          c1.send JSON.generate(:type => :move, :location => 2 ) if move_number == 3
        end
      end
      
      c2.stream do |msg|
        msg = JSON.parse! msg
        if msg["type"] == "move_request" then
          move_number += 1
          msg["your_mark"].should == "O"
          c2.send JSON.generate(:type => :move, :location => 1 ) if move_number == 2
          done if move_number == 4
        end
      end
    end
  end
  
  it "should accept moves only from the current_player" do
    em do
      ais = create_server
      ais.start
      
      c1 = create_client
      c2 = create_client
      
      c1.stream do |msg|
        msg = JSON.parse! msg
        
        c1.send JSON.generate(:type => :create, :game => "tic-tac-toe") if msg["type"] == "greeting"
        c2.send JSON.generate(:type => :join, :game_id => msg["game_id"]) if msg["type"] == "created"
        c2.send JSON.generate(:type => :move, :location => 0) if msg["type"] == "move_request"
      end
      
      c2.stream do |msg|
        msg = JSON.parse! msg
        done if msg["type"] == "error"
      end
    end
  end
  
  it "should detect a winning scenario" do
    em do
      ais = create_server
      ais.start
      
      c1 = create_client
      c2 = create_client
      
      move_number = 0
      winner = false
      loser = false
      
      c1.stream do |msg|
       msg = JSON.parse! msg

       c1.send JSON.generate(:type => :create, :game => "tic-tac-toe") if msg["type"] == "greeting"
       c2.send JSON.generate(:type => :join, :game_id => msg["game_id"]) if msg["type"] == "created"
       
       if msg["type"] == "move_request" then
         move_number += 1
         c1.send JSON.generate(:type => :move, :location => 0) if move_number == 1
         c1.send JSON.generate(:type => :move, :location => 1) if move_number == 3
         c1.send JSON.generate(:type => :move, :location => 2) if move_number == 5
       end
       
       winner = true if msg["type"] == "game_over" && msg["result"] == "win"
       done if winner && loser
     end

     c2.stream do |msg|
       msg = JSON.parse! msg
       
       if msg["type"] == "move_request" then
         move_number += 1
         c2.send JSON.generate(:type => :move, :location => 6 ) if move_number == 2
         c2.send JSON.generate(:type => :move, :location => 7 ) if move_number == 4
       end
       
       loser = true if msg["type"] == "game_over" && msg["result"] == "lose"
       done if winner && loser
     end
    end
  end
  
  it "should detect a draw scenario" do
    em do
      ais = create_server
      ais.start
      
      c1 = create_client
      c2 = create_client
      
      move_number = 0
      tie_number = 0
      
      c1.stream do |msg|
       msg = JSON.parse! msg

       c1.send JSON.generate(:type => :create, :game => "tic-tac-toe") if msg["type"] == "greeting"
       c2.send JSON.generate(:type => :join, :game_id => msg["game_id"]) if msg["type"] == "created"
       
       if msg["type"] == "move_request" then
         move_number += 1
         c1.send JSON.generate(:type => :move, :location => 0) if move_number == 1
         c1.send JSON.generate(:type => :move, :location => 2) if move_number == 3
         c1.send JSON.generate(:type => :move, :location => 7) if move_number == 5
         c1.send JSON.generate(:type => :move, :location => 3) if move_number == 7
         c1.send JSON.generate(:type => :move, :location => 5) if move_number == 9
       end
       
       tie_number += 1 if msg["type"] == "game_over" && msg["result"] == "tie"
       done if tie_number == 2
     end

     c2.stream do |msg|
       msg = JSON.parse! msg
       
       if msg["type"] == "move_request" then
         move_number += 1
         c2.send JSON.generate(:type => :move, :location => 6 ) if move_number == 2
         c2.send JSON.generate(:type => :move, :location => 8 ) if move_number == 4
         c2.send JSON.generate(:type => :move, :location => 1 ) if move_number == 6
         c2.send JSON.generate(:type => :move, :location => 4 ) if move_number == 8
       end
       
       tie_number += 1 if msg["type"] == "game_over" && msg["result"] == "tie"
       done if tie_number == 2
     end
    end
  end
end