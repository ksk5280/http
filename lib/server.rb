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
    puts "Ready for a request"
    @request_lines = []
    while line = client.gets and !line.chomp.empty?
      request_lines << line.chomp
    end

    parser.set_request(request_lines)

    puts "Got this request:"
    puts request_lines.inspect

    send_response

    @request_count += 1 unless parser.path == '/favicon.ico'

    client.close
  end

  def send_response
    if parser.path == '/hello'
      @hello_count += 1
      response = "Hello, World! (#{hello_count})"
    elsif parser.path == '/datetime'
      response = DateTime.now.strftime('%I:%M%p on %A, %B %-d, %Y')
    elsif parser.path == '/request'
      response = "Total Requests: #{request_count}"
    elsif parser.path == '/shutdown'
      response = "Total Requests: #{request_count}"
      @shutdown = parser.path == '/shutdown'
    else
      response = generate_diagnostic
    end

    output = "<http><head></head><body>#{response}</body></html>"
    client.puts headers(output)
    client.puts output
  end

  def headers(output)
    ["http/1.1 200 ok",
      "date: #{Time.now.strftime('%a, %e %b %Y %H:%M:%S %z')}",
      "server: ruby",
      "content-type: text/html; charset=iso-8859-1",
      "content-length: #{output.length}\r\n\r\n"].join("\r\n")
  end

  # def verb
  #   request_lines[0].split[0]
  # end

  # def parser.path
  #   request_lines[0].split[1]
  # end

  def protocol
    request_lines[0].split[2]
  end

  def host
    request_lines.find { |line| line.start_with?('Host') }.split[1].split(':')[0]
  end

  def port
    request_lines.find { |line| line.start_with?('Host') }.split(":")[2]
  end

  def origin
    host
  end

  def accept
    request_lines.find { |line| line.start_with?('Accept:') }[8..-1]
  end

  def generate_diagnostic
    "<pre>\n" \
    "Verb: #{parser.verb}\n" \
    "Path: #{parser.path}\n" \
    "Protocol: #{protocol}\n" \
    "Host: #{host}\n" \
    "Port: #{port}\n" \
    "Origin: #{origin}\n" \
    "Accept: #{accept}\n" \
    '</pre>'
  end
end

if __FILE__ == $0
  serve = Server.new
  serve.run
end
