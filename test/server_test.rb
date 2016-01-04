require 'test_helper'
require 'hurley'
require 'minitest'
require 'server'

class ServerTest < Minitest::Test
  attr_reader :hclient
  def setup
    @hclient = Hurley::Client.new "http://127.0.0.1:9292"
  end

  def test_returns_calling_the_correct_host
    response = hclient.get("/")
    assert_equal response.header[:server], "ruby"
  end

  def test_responds_to_different_paths
    response = hclient.get("/")
    assert_equal hclient.port, 9292
  end


end
