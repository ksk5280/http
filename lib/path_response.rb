class PathResponse
  attr_reader :hello_count, :word
  
  def path_finder(path, hello_count, word, generate_diagnostic)
    @word = word
    @hello_count = hello_count
    if path == '/'
      generate_diagnostic
    else
      response_method = path[1..-1].to_sym
      send(response_method)
    end
  end

  def hello
    "Hello, World! (#{hello_count})"
  end

  def datetime
    DateTime.now.strftime('%I:%M%p on %A, %B %-d, %Y')
  end

  def request
    "Total Requests: #{request_count}"
  end

  def shutdown
    request
  end

  def word_search
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
