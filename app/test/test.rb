ENV['APP_ENV'] = 'test'

require_relative '../app'
require 'socket'
require 'rack/test'
require 'test/unit'

class AppTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_it_says_current_hostname
    get '/'
    assert last_response.ok?
    assert_equal "Hostname: #{Socket.gethostname}", last_response.body
  end
end