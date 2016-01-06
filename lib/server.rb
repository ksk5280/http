require 'socket'
require 'hurley'
require 'pry'
require_relative 'parser'
require_relative 'path_response'

class Server
  attr_reader :tcp_server,
              :client,
              :shutdown,
              :request_count,
              :request_lines,
              # :hello_count,
              :parser,
              :path_response

  def initialize
    @tcp_server = TCPServer.new(9292)
    @request_count = 0
    # @hello_count = 0
    @shutdown = false
    @parser = Parser.new
    @path_response = PathResponse.new
  end

  def run
    while !shutdown
      accept_request
    end
  end

  def accept_request
    @client = tcp_server.accept
    get_request_lines
    parser.set_request(request_lines)
    print_request
    send_response
    @request_count += 1 unless parser.path == '/favicon.ico'
    client.close
  end

  def get_request_lines
    puts "Ready for a request"
    @request_lines = []
    while line = client.gets and !line.chomp.empty?
      request_lines << line.chomp
    end
  end

  def print_request
    puts "Got this request:"
    puts request_lines.inspect
  end

  def send_response
    response = path_finder
    output = "<http><head></head><body>#{response}</body></html>"
    client.puts headers(output)
    client.puts output
  end

  def path_finder
    case path
    when '/hello'
      path_response.hello_response
    when '/datetime'
      path_response.datetime_response
    when '/request'
      path_response.request_response
    when '/shutdown'
      @shutdown = path == '/shutdown'
      path_response.shutdown_response
    when '/word_search'
      path_response.word_response(parser.word)
    else
      generate_diagnostic
    end
  end
  #
  # def hello_response
  #   @hello_count += 1
  #   "Hello, World! (#{hello_count})"
  # end

  # def datetime_response
  #   DateTime.now.strftime('%I:%M%p on %A, %B %-d, %Y')
  # end
  #
  # def request_response
  #   "Total Requests: #{request_count}"
  # end

  # def shutdown_response
  #   @shutdown = path == '/shutdown'
  #   request_response
  # end
  #
  # def word_response
  #   word = parser.word
  #   if dictionary.include?(word)
  #     "#{word} is a known word"
  #   else
  #     "#{word} is not a known word"
  #   end
  # end

  # def dictionary
  #   File.read('/usr/share/dict/words').split("\n")
  # end

  def path
    parser.path
  end

  def headers(output)
    ["http/1.1 200 ok",
      "date: #{Time.now.strftime('%a, %e %b %Y %H:%M:%S %z')}",
      "server: ruby",
      "content-type: text/html; charset=iso-8859-1",
      "content-length: #{output.length}\r\n\r\n"].join("\r\n")
  end

  def generate_diagnostic
    parser.generate_diagnostic
  end
end

if __FILE__ == $0
  serve = Server.new
  serve.run
end
