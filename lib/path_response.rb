

class PathResponse
  attr_reader :hello_count

  def initialize
    @hello_count = 0
  end

  def hello_response
    @hello_count += 1
    "Hello, World! (#{hello_count})"
  end

  def datetime_response
    DateTime.now.strftime('%I:%M%p on %A, %B %-d, %Y')
  end

  def request_response
    "Total Requests: #{request_count}"
  end

  def shutdown_response
    request_response
  end

  def word_response(word)
    if dictionary.include?(word)
      "#{word} is a known word"
    else
      "#{word} is not a known word"
    end
  end

  def dictionary
    File.read('/usr/share/dict/words').split("\n")
  end
end
