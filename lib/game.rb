class Game
  attr_reader :num, :guess_count
  def initialize(num = rand(1000))
    @num = num
    @guess_count = 0
  end

  def guess(guessed)
    @guess_count += 1
    if guessed < num
      status = "low"
    elsif guessed == num
      status = "correct"
    else
      status = "high"
    end
    [guessed, status]
  end

end
