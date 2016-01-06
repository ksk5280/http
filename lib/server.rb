require 'socket'
require 'hurley'
require 'pry'
require_relative 'parser'

class Server
  attr_reader :tcp_server,
              :client,
              :shutdown,
              :request_count,
              :request_lines,
              :hello_count,
              :parser

  def initialize
    @tcp_server = TCPServer.new(9292)
    @request_count = 0
    @hello_count = 0
    @shutdown = false
    @parser = Parser.new
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
    if path == '/hello'
      @hello_count += 1
      "Hello, World! (#{hello_count})"
    elsif path == '/datetime'
      DateTime.now.strftime('%I:%M%p on %A, %B %-d, %Y')
    elsif path == '/request'
      "Total Requests: #{request_count}"
    elsif path == '/shutdown'
      @shutdown = path == '/shutdown'
      "Total Requests: #{request_count}"
    else
      generate_diagnostic
    end
  end

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
