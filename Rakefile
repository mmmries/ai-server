require File.expand_path('lib/ai_server', File.dirname(__FILE__))

desc "starts the server in the console"
task :run do
  EM.run do
    ais = AIS::Server.new(:host => '0.0.0.0', :port => 8888)
    ais.start
  end
end