ENV['APP_ENV'] = 'test'

require_relative '../app'
require 'socket'
require 'rack/test'
require 'test/unit'

class AppTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    ::Sinatra::Application
  end

  def test_homepage_returns_ok
    get '/'
    assert last_response.ok?
  end

  def test_homepage_is_html
    get '/'
    assert_match %r{text/html}, last_response.content_type
  end

  def test_homepage_contains_hostname
    get '/'
    assert_include last_response.body, Socket.gethostname
  end

  def test_homepage_has_expected_sections
    get '/'
    body = last_response.body
    %w[About Skills Projects Contact].each do |section|
      assert_include body, section, "Expected section '#{section}' not found"
    end
  end

  def test_css_is_accessible
    get '/css/style.css'
    assert last_response.ok?
    assert_match %r{text/css}, last_response.content_type
  end
end
