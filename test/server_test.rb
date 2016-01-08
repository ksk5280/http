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

  def test_word_search_can_check_known_words
    response = hclient.get("/word_search?word=hello&word2=world")

    assert_equal "<http><head></head><body>hello is a known word</body></html>", response.body
  end

  def test_word_search_can_check_unknown_words
    response = hclient.get("/word_search?word=pizz")

    assert_equal "<http><head></head><body>pizz is not a known word</body></html>", response.body
  end

  def test_can_respond_to_start_game
    response = hclient.post("/start_game")
    assert_equal "<http><head></head><body>Good luck!</body></html>", response.body
  end

  def test_increments_guess_count_with_a_post
    response = hclient.post("/start_game")
    response = hclient.post("/game",guess: 2000)
    assert_equal 1, response.body.match(/\d+/)[0].to_i
    response = hclient.post("/game", guess: 100)
    assert_equal 2, response.body.match(/\d+/)[0].to_i
  end

  def test_tells_last_guess_and_guess_is_high
    response = hclient.post("/start_game")
    response = hclient.post("/game",guess: 2000)
    assert_equal "<http><head></head><body>Number of guesses = 1\nLast guess: 2000\nYour guess was too high</body></html>", response.body
  end

  def test_tells_last_guess_and_guess_is_low
    response = hclient.post("/start_game")
    response = hclient.post("/game",guess: -5)
    assert_equal "<http><head></head><body>Number of guesses = 1\nLast guess: -5\nYour guess was too low</body></html>", response.body
  end

  # def test_shutdown_return_total_number_of_requests_and_closes_server
  #
  #   response = hclient.get('/request')
  #   req_num = response.body[/\d+/].to_i
  #   req_string = "<http><head></head><body>Total Requests: #{req_num + 1}</body></html>"
  #   response = hclient.get("/shutdown")
  #   assert_equal req_string, response.body
  #   # refute response.success?
  # end

end
