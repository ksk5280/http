require_relative 'parser'
require_relative 'response_generator'
require 'socket'
require 'pry'

class Server
  attr_reader :tcp_server,
              :client,
              :request_count,
              :request_lines,
              :request_details,
              :hello_count,
              :parser,
              :response_gen

  def initialize
    @tcp_server = TCPServer.new(9292)
    @parser = Parser.new
    @response_gen = ResponseGenerator.new
    @request_count = 0
    @hello_count = 0
  end

  def run
    loop do
      process_request
      break if shutdown?
    end
  end

  def process_request
    @client = tcp_server.accept
    puts "Ready for a request"
    load_request_lines
    print_raw_request
    parse_request
    increment_counters
    response = generate_response
    send_response(response)
    client.close
  end

  def load_request_lines
    @request_lines = []
    while line = client.gets and !line.chomp.empty?
      request_lines << line.chomp
    end
  end

  def print_raw_request
    puts "Got this request:"
    puts request_lines.inspect
  end

  def parse_request
    @request_details = parser.parse_request(request_lines)
  end

  def increment_counters
    @request_count += 1
    @hello_count += 1 if path == '/hello'
  end

  def generate_response
    server_data = {hello_count: hello_count,
                   request_count: request_count,
                   request_details: request_details}
    response_gen.generate_response(path,server_data)
  end

  def send_response(response)
    output = "<http><head></head><body>#{response}</body></html>"
    client.puts headers(output)
    client.puts output
  end

  def shutdown?
    path == '/shutdown'
  end

  def path
    request_details["Path"]
  end

  def headers(output)
    ["http/1.1 200 ok",
      "date: #{Time.now.strftime('%a, %e %b %Y %H:%M:%S %z')}",
      "server: ruby",
      "content-type: text/html; charset=iso-8859-1",
      "content-length: #{output.length}\r\n\r\n"].join("\r\n")
  end

end

if __FILE__ == $0
  serve = Server.new
  serve.run
end
