class Game
  attr_reader :num, :guess_count, :last_guess, :status
  def initialize(num = rand(1000))
    @num = num
    @guess_count = 0
  end

  def guess(guessed)
    @guess_count += 1
    @last_guess = guessed
    if guessed < num
      @status = "too low"
    elsif guessed == num
      @status = "correct!@!!$&&!@ OMG!!! lol :)"
    else
      @status = "too high"
    end
  end

end
