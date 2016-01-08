require 'hurley'
require 'minitest'

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
    hw_string = "<http><head></head><body>" \
                "Hello, World! (#{hw_num})" \
                "</body></html>"
    assert_equal hw_string, response.body

    response = hclient.get("/hello")
    hw_num = response.body[/\d+/].to_i
    hw_string = "<http><head></head><body>" \
                "Hello, World! (#{hw_num})" \
                "</body></html>"
    assert_equal hw_string, response.body

    response = hclient.get("/hello")
    hw_num = response.body[/\d+/].to_i
    hw_string = "<http><head></head><body>" \
                "Hello, World! (#{hw_num})" \
                "</body></html>"
    assert_equal hw_string, response.body
  end

  def test_prints_get_verb_from_request
    response = hclient.get('/')
    assert_equal "GET", response.body.split("\n")[1].split[1]
  end

  def test_prints_post_verb_from_request
    response = hclient.post('/')
    assert_equal "POST", response.body.split("\n")[1].split[1]
  end

  def test_prints_diagnostic_correctly
    response = hclient.get('/')
    expected =  "<http><head></head><body><pre>\n" \
                "Verb: GET\n" \
                "Path: /\n" \
                "Protocol: HTTP/1.1\n" \
                "Host: 127.0.0.1\n" \
                "Port: 9292\n" \
                "Origin: 127.0.0.1\n" \
                "Accept: */*\n" \
                "</pre></body></html>"
    assert_equal expected, response.body
  end

  def test_can_send_a_unknown_path
    response = hclient.get('/omglol')
    expected =  "<http><head></head><body><pre>\n" \
                "Verb: GET\n" \
                "Path: /omglol\n" \
                "Protocol: HTTP/1.1\n" \
                "Host: 127.0.0.1\n" \
                "Port: 9292\n" \
                "Origin: 127.0.0.1\n" \
                "Accept: */*\n" \
                "</pre></body></html>"
    assert_equal expected, response.body
  end

  def test_hello_world_only_increments_on_hello_call
    response = hclient.get("/hello")
    hw_num = response.body[/\d+/].to_i
    hw_string = "<http><head></head><body>" \
                "Hello, World! (#{hw_num})" \
                "</body></html>"
    assert_equal hw_string, response.body

    response = hclient.get("/")
    hw_num += 1
    hw_string = "<http><head></head><body>" \
                "Hello, World! (#{hw_num})" \
                "</body></html>"
    response = hclient.get("/hello")
    assert_equal hw_string, response.body
  end

  def test_returns_datetime_in_correct_format
    response = hclient.get("/datetime")
    expected = "<http><head></head><body>" \
               "#{DateTime.now.strftime('%I:%M%p on %A, %B %-d, %Y')}" \
               "</body></html>"
    assert_equal expected, response.body
  end

  def test_word_search_can_check_known_words
    response = hclient.get("/word_search?word=hello&word2=world")
    expected = "<http><head></head><body>" \
               "hello is a known word" \
               "</body></html>"
    assert_equal expected, response.body
  end

  def test_word_search_can_check_unknown_words
    response = hclient.get("/word_search?word=pizz")
    expected = "<http><head></head><body>" \
               "pizz is not a known word" \
               "</body></html>"
    assert_equal expected, response.body
  end

  def test_can_respond_to_start_game
    response = hclient.post("/start_game")
    expected = "<http><head></head><body>" \
               "Good luck!" \
               "</body></html>"
    assert_equal expected, response.body
  end

  def test_increments_guess_count_with_a_post
    response = hclient.post("/start_game")
    response = hclient.post("/game", guess: 2000)
    assert_equal 1, response.body.match(/\d+/)[0].to_i
    response = hclient.post("/game", guess: 100)
    assert_equal 2, response.body.match(/\d+/)[0].to_i
  end

  def test_tells_last_guess_and_guess_is_high
    response = hclient.post("/start_game")
    response = hclient.post("/game", guess: 2000)
    expected = "<http><head></head><body>" \
               "Number of guesses = 1\n" \
               "Last guess: 2000\n" \
               "Your guess was too high" \
               "</body></html>"
    assert_equal expected, response.body
  end

  def test_tells_last_guess_and_guess_is_low
    response = hclient.post("/start_game")
    response = hclient.post("/game", guess: -5)
    expected = "<http><head></head><body>" \
               "Number of guesses = 1\n" \
               "Last guess: -5\n" \
               "Your guess was too low" \
               "</body></html>"
    assert_equal expected, response.body
  end

  def test_can_returns_total_number_of_requests
    response = hclient.get('/request')
    req_num = response.body[/\d+/].to_i
    req_string = "<http><head></head><body>" \
                "Total Requests: #{req_num}" \
                "</body></html>"
    assert_equal req_string, response.body
  end
end
