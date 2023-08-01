require 'sinatra'
require 'socket'

get '/' do
  "Hostname: #{Socket.gethostname}"
end
