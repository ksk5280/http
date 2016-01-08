require 'test_helper'
require 'minitest'
require 'path_response'
require 'game'

class PathResponseTest < Minitest::Test
  def test_responds_with_diagnostics_for_unknown_path
    pr = PathResponse.new
    data_in = {diagnostics: "Diagnostics go here"}
    assert_equal "Diagnostics go here", pr.path_finder('/omglol', 'GET', data_in)
  end

  def test_path_hello_responds_with_hello_world_with_count
    pr = PathResponse.new
    data_in = {hello_count: 4}
    assert_equal "Hello, World! (4)", pr.path_finder('/hello', 'GET', data_in)
  end

  def test_path_datetime_responds_with_formatted_time
    pr = PathResponse.new
    data_in = {}
    dt = Time.now.strftime('%I:%M%p on %A, %B %-d, %Y')
    assert_equal dt, pr.path_finder('/datetime', 'GET', data_in)
  end

  def test_path_request_responds_with_total_number_of_requests
    pr = PathResponse.new
    data_in = {request_count: 6}
    assert_equal "Total Requests: 6",
    pr.path_finder('/request', 'GET', data_in)
  end

  def test_path_shutdown_responds_with_total_number_of_requests
    pr = PathResponse.new
    data_in = {request_count: 6}
    assert_equal "Total Requests: 6",
    pr.path_finder('/shutdown', 'GET', data_in)
  end

  def test_path_wordsearch_responds_for_known_word
    pr = PathResponse.new
    data_in = {word: "dog"}
    assert_equal "dog is a known word",
    pr.path_finder('/word_search', 'GET', data_in)
  end

  def test_path_wordsearch_responds_for_unknown_word
    pr = PathResponse.new
    data_in = {word: "jort"}
    assert_equal "jort is not a known word",
    pr.path_finder('/word_search', 'GET', data_in)
  end

  def test_path_start_game_responds_with_good_luck
    pr = PathResponse.new
    data_in = {}
    assert_equal "Good luck!",
    pr.path_finder('/start_game', 'POST', data_in)
  end

  def test_path_game_responds_with_game_status
    pr = PathResponse.new
    g = Game.new()
    3.times {|n| g.guess(n*(-1)-1)}
    data_in = {game: g}
    game_response = "Number of guesses = 3\n" \
    "Last guess: -3\n"\
    "Your guess was too low"
    assert_equal game_response,
    pr.path_finder('/game', 'GET', data_in)
  end

  def test_path_game_responds_nil_when_called_with_post
    pr = PathResponse.new
    g = Game.new()
    3.times {|n| g.guess(n*(-1)-1)}
    data_in = {game: g}
    assert_nil pr.path_finder('/game', 'POST', data_in)
  end
end
