require 'test_helper'
require 'parser'

class ParserTest < Minitest::Test
  def test_can_parse_simple_path
    parser = Parser.new
    request = ["GET / HTTP/1.1", "User-Agent: Hurley v0.2", "Accept-Encoding: gzip;q=1.0,deflate;q=0.6,identity;q=0.3", "Accept: */*", "Connection: close", "Host: 127.0.0.1:9292"]

    parser.set_request(request)
    assert_equal "/", parser.path
  end

  def test_can_parse_word_search_with_parameters
    parser = Parser.new
    request = ["GET /word_search?word=hello&word2=world HTTP/1.1", "User-Agent: Hurley v0.2", "Accept-Encoding: gzip;q=1.0,deflate;q=0.6,identity;q=0.3", "Accept: */*", "Connection: close", "Host: 127.0.0.1:9292"]
    parser.set_request(request)
    assert_equal '/word_search', parser.path
  end

  def test_can_extract_word_from_word_search_path_single_parameter
    parser = Parser.new
    request = ["GET /word_search?word=hello HTTP/1.1", "User-Agent: Hurley v0.2", "Accept-Encoding: gzip;q=1.0,deflate;q=0.6,identity;q=0.3", "Accept: */*", "Connection: close", "Host: 127.0.0.1:9292"]
    parser.set_request(request)
    assert_equal "hello", parser.word
  end

  def test_can_extract_word_from_word_search_path_multiple_parameters
    parser = Parser.new
    request = ["GET /word_search?word=hello&word2=world HTTP/1.1", "User-Agent: Hurley v0.2", "Accept-Encoding: gzip;q=1.0,deflate;q=0.6,identity;q=0.3", "Accept: */*", "Connection: close", "Host: 127.0.0.1:9292"]
    parser.set_request(request)
    assert_equal "hello", parser.word
  end

  def test_can_get_the_body_of_a_post
    parser = Parser.new
    request = ["POST / HTTP/1.1", "User-Agent: Hurley v0.2", "Accept-Encoding: gzip;q=1.0,deflate;q=0.6,identity;q=0.3", "Accept: */*", "Connection: close", "Host: 127.0.0.1:9292", "", "This is my body"]
    parser.set_request(request)
    assert_equal "This is my body", parser.body
  end

  def test_can_parse_a_guess_the_body_of_a_post
    parser = Parser.new
    request = ["Post /game HTTP/1.1", "User-Agent: Hurley v0.2", "Accept-Encoding: gzip;q=1.0,deflate;q=0.6,identity;q=0.3", "Accept: */*", "Connection: close", "Host: 127.0.0.1:9292", "", "guess=35"]
    parser.set_request(request)
    assert_equal 35, parser.guess
  end

  def test_can_parse_a_guess_that_is_negative
    parser = Parser.new
    request = ["Post /game HTTP/1.1", "User-Agent: Hurley v0.2", "Accept-Encoding: gzip;q=1.0,deflate;q=0.6,identity;q=0.3", "Accept: */*", "Connection: close", "Host: 127.0.0.1:9292", "", "guess=-71"]
    parser.set_request(request)
    assert_equal -71, parser.guess
  end

  def test_doesnt_return_a_guess_if_not_in_body
    parser = Parser.new
    request = ["POST /game HTTP/1.1", "User-Agent: Hurley v0.2", "Accept-Encoding: gzip;q=1.0,deflate;q=0.6,identity;q=0.3", "Accept: */*", "Connection: close", "Host: 127.0.0.1:9292", "", "not_a_guess"]
    parser.set_request(request)
    assert_nil parser.guess
  end

  def test_can_get_content_length
    parser = Parser.new
    request = ["POST /game HTTP/1.1", "User-Agent: Hurley v0.2", "Content-Length: 0", "Accept-Encoding: gzip;q=1.0,deflate;q=0.6,identity;q=0.3", "Accept: */*", "Connection: close", "Host: 127.0.0.1:9292", "", "not_a_guess"]
    parser.set_request(request)
    assert_equal 0, parser.content_length
  end

  def test_returns_zero_if_there_is_no_content_length_field
    parser = Parser.new
    request = ["POST /game HTTP/1.1", "User-Agent: Hurley v0.2", "Accept-Encoding: gzip;q=1.0,deflate;q=0.6,identity;q=0.3", "Accept: */*", "Connection: close", "Host: 127.0.0.1:9292", "", "not_a_guess"]
    parser.set_request(request)
    assert_equal 0, parser.content_length
  end

  def test_content_length_is_greater_than_zero
    parser = Parser.new
    request = ["POST /game HTTP/1.1", "User-Agent: Hurley v0.2", "Content-Length: 10", "Accept-Encoding: gzip;q=1.0,deflate;q=0.6,identity;q=0.3", "Accept: */*", "Connection: close", "Host: 127.0.0.1:9292", "", "not_a_guess"]
    parser.set_request(request)
    assert_equal 10, parser.content_length
  end
end
