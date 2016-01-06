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
end
