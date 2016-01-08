require 'test_helper'
require 'game'

class GameTest < Minitest::Test
  def test_can_start_a_game
    g = Game.new(35)
    assert_equal 35, g.num
  end

  def test_starts_a_game_with_random_number
    g = Game.new
    assert g.num.kind_of?(Fixnum)
  end

  def test_starts_with_no_guess
    g = Game.new(35)
    assert_equal 0, g.guess_count
  end

  def test_can_guessing_increments_the_guess_count
    g = Game.new(35)
    g.guess(20)
    assert_equal 1, g.guess_count
    g.guess(30)
    assert_equal 2, g.guess_count
  end

  def test_can_check_if_guess_is_too_high
    g = Game.new(35)
    g.guess(200)
    assert_equal 200, g.last_guess
    assert_equal "too high", g.status
  end

  def test_can_check_if_guess_is_too_low
    g = Game.new(35)
    g.guess(2)
    assert_equal 2, g.last_guess
    assert_equal "too low", g.status
  end

  def test_can_check_if_guess_is_correct
    g = Game.new(35)
    g.guess(35)
    assert_equal 35, g.last_guess
    assert_equal "correct!@!!$&&!@ OMG!!! lol :)", g.status
  end



end
