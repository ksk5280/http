class PathResponse
  attr_reader :data

  def path_finder(path, data_in)
    @data = data_in
    if path == '/' || path == '/favicon.ico'
      data[:diagnostics]
    else
      response_method = path[1..-1].to_sym
      send(response_method)
    end
  end

  def hello
    "Hello, World! (#{data[:hello_count]})"
  end

  def datetime
    DateTime.now.strftime('%I:%M%p on %A, %B %-d, %Y')
  end

  def request
    "Total Requests: #{data[:request_count]}"
  end

  def shutdown
    request
  end

  def word_search
    if dictionary.include?(data[:word])
      "#{data[:word]} is a known word"
    else
      "#{data[:word]} is not a known word"
    end
  end

  def start_game
    "Good luck!"
  end

  def game
    "You guessed 46"
  end

  def dictionary
    File.read('/usr/share/dict/words').split("\n")
  end
end
