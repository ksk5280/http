require 'socket'
require 'hurley'

class Server
  attr_reader :tcp_server,
              :client,
              :request_count,
              :request_lines,
              :request_details

  def initialize
    @tcp_server = TCPServer.new(9292)
    @request_count = 0
  end

  def accept_request
    @client = tcp_server.accept
    puts "Ready for a request"
    @request_lines = []
    while line = client.gets and !line.chomp.empty?
      request_lines << line.chomp
    end
    puts "Got this request:"
    puts request_lines.inspect
    require 'pry'
    binding.pry
    @request_count += 1
    send_response
    client.close
  end

  def send_response
    #parse the request lines
    response = "<pre>" + request_lines.join("\n") + "</pre>"
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

  def parse_request
    @request_details = {}
    request_details["Verb"] = request_lines[0].split[0]
    request_details["Path"] = request_lines[0].split[1]
    request_details["Protocol"] = request_lines[0].split[2]
    request_details["Host"] = request_lines[1].split(":")[1]
    request_details["Port"] = request_lines[1].split(":")[2]
    request_details["Origin"] = "I have no idea"
    request_details["Accept"] = ""
  end
end

if __FILE__ == $0
  serve = Server.new
  loop do
    serve.accept_request
  end
end
