require 'helper'
require 'em-http-request'
require 'ai_server'

describe AIS::Game::Test do
  include EM::SpecHelper
  default_timeout 1.0
  
  it "should generate ai players for games"
  it "should request a move from the client"
  it "should accept a move from the client"
  it "should report the end of the game to the client"
end