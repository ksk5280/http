require 'socket'
require 'pry'

class Server
  attr_reader :tcp_server,
              :client,
              :request_count,
              :request_lines,
              :request_details,
              :hello_count

  def initialize
    @tcp_server = TCPServer.new(9292)
    @request_count = 0
    @hello_count = 0
  end

  def run
    loop do
      process_request
      break if get_path == '/shutdown'
    end
  end

  def process_request
    @client = tcp_server.accept
    puts "Ready for a request"
    load_request_lines
    @request_count += 1
    print_raw_request
    parse_request
    send_response
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
  def send_response
    if get_path == '/hello'
      @hello_count += 1
      response = "Hello, World! (#{hello_count})"
    elsif get_path == '/datetime'
      response = Time.now.strftime('%I:%M%p on %A, %B %-d, %Y')
    elsif get_path == '/request'
      response = "Total Requests: #{request_count}"
    elsif get_path == '/shutdown'
      response = "Total Requests: #{request_count}"
    else
      response = generate_diagnostic
    end

    output = "<http><head></head><body>#{response}</body></html>"
    client.puts headers(output)
    client.puts output
  end

  def get_path
    request_lines[0].split[1]
  end

  def headers(output)
    ["http/1.1 200 ok",
      "date: #{Time.now.strftime('%a, %e %b %Y %H:%M:%S %z')}",
      "server: ruby",
      "content-type: text/html; charset=iso-8859-1",
      "content-length: #{output.length}\r\n\r\n"].join("\r\n")
  end

  def parse_request
    @request_details = {}
    request_details["Verb"] = request_lines[0].split[0]
    request_details["Path"] = request_lines[0].split[1]
    request_details["Protocol"] = request_lines[0].split[2]
    request_details["Host"] = get_host
    request_details["Port"] = get_port
    request_details["Origin"] = get_host
    request_details["Accept"] = get_accept
  end

  def get_host
    request_lines.find { |line| line.start_with?('Host') }.split[1].split(':')[0]
  end

  def get_port
    request_lines.find { |line| line.start_with?('Host') }.split(":")[2]
  end

  def get_accept
    request_lines.find { |line| line.start_with?('Accept:') }[8..-1]
  end

  def generate_diagnostic
    diagnostic = "<pre>\n"
    diagnostic += "Verb: #{request_details['Verb']}\n"
    diagnostic += "Path: #{request_details['Path']}\n"
    diagnostic += "Protocol: #{request_details['Protocol']}\n"
    diagnostic += "Host: #{request_details['Host']}\n"
    diagnostic += "Port: #{request_details['Port']}\n"
    diagnostic += "Origin: #{request_details['Origin']}\n"
    diagnostic += "Accept: #{request_details['Accept']}\n"
    diagnostic += '</pre>'
  end


end

if __FILE__ == $0
  serve = Server.new
  serve.run
end
