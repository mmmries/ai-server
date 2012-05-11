require 'helper'
require 'em-http-request'
require 'ai_server'

describe "AIS::Game::TicTacToe" do
  include EM::SpecHelper
  default_timeout 1.0
  
  it "should accept 2 and only 2 clients"
  it "should request moves in alternating fashion"
  it "should detect a winning scenario"
  it "should detect a draw scenario"
end