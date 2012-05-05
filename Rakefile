require File.expand_path('lib/ai_server', File.dirname(__FILE__))

desc "starts the server in the console"
task :run do
  EM.run do
    ais = AIServer.new
    ais.start
  end
end