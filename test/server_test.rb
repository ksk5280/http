require 'test_helper'
require 'hurley'
require 'minitest'
require 'server'
require 'pry'

class ServerTest < Minitest::Test
  attr_reader :hclient
  def setup
    @hclient = Hurley::Client.new "http://127.0.0.1:9292"
  end

  def test_can_request_from_server
    response = hclient.get("/")
    assert response.success?
  end

  def test_hello_world_increments
    response = hclient.get("/hello")
    hw_num = response.body[/\d+/].to_i
    hw_string = "<http><head></head><body>Hello, World! (#{hw_num})</body></html>"
    assert_equal hw_string, response.body
    hw_num += 1
    hw_string = "<http><head></head><body>Hello, World! (#{hw_num})</body></html>"
    response = hclient.get("/hello")
    assert_equal hw_string, response.body
  end

  def test_prints_verb_from_request
    response = hclient.get('/')
    assert_equal "GET", response.body.split("\n")[1].split[1]
  end

  def test_prints_diagnostic_correctly
    response = hclient.get('/')
    assert_equal "<http><head></head><body><pre>\nVerb: GET\nPath: /\nProtocol: HTTP/1.1\nHost: 127.0.0.1\nPort: 9292\nOrigin: 127.0.0.1\nAccept: */*\n</pre></body></html>", response.body
  end

  def test_hello_world_only_increments_on_hello_call
    response = hclient.get("/hello")
    hw_num = response.body[/\d+/].to_i
    hw_string = "<http><head></head><body>Hello, World! (#{hw_num})</body></html>"
    assert_equal hw_string, response.body

    response = hclient.get("/")

    hw_num += 1
    hw_string = "<http><head></head><body>Hello, World! (#{hw_num})</body></html>"
    response = hclient.get("/hello")
    assert_equal hw_string, response.body
  end

  def test_returns_datetime_in_correct_format
    response = hclient.get("/datetime")

    d = "<http><head></head><body>#{DateTime.now.strftime('%I:%M%p on %A, %B %-d, %Y')}</body></html>"

    assert_equal d, response.body
  end

  def test_shutdown_return_total_number_of_requests_and_closes_server
    response = hclient.get('/request')
    req_num = response.body[/\d+/].to_i
    req_string = "<http><head></head><body>Total Requests: #{req_num + 1}</body></html>"
    response = hclient.get("/shutdown")
    assert_equal req_string, response.body
    # refute response.success?
  end

end
