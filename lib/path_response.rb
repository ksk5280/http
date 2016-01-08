class PathResponse
  attr_reader :data, :verb

  def path_finder(path, verb, data_in)
    @data = data_in
    @verb = verb
    response_method = path.delete('/').to_sym
    if respond_to?(response_method)
      send(response_method)
    else
      data[:diagnostics]
    end
  end

  def hello
    "Hello, World! (#{data[:hello_count]})"
  end

  def datetime
    Time.now.strftime('%I:%M%p on %A, %B %-d, %Y')
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
    if verb == "GET"
      "Number of guesses = #{data[:game].guess_count}\n" \
      "Last guess: #{data[:game].last_guess}\n"\
      "Your guess was #{data[:game].status}" #\
      #"The actual number is #{data[:game].num}"
    end
  end

  def dictionary
    File.read('/usr/share/dict/words').split("\n")
  end
end
