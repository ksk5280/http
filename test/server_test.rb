require 'test_helper'
require 'hurley'
require 'minitest'
require 'server'

class ServerTest < Minitest::Test
  def test_listens_to_port_9292
    response = Hurley.get("http://127.0.0.1:9292")
    assert_equal response.body, "<http><head></head><body>Hello, World! (6)</body></html>"
  end

  
end
