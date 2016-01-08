$LOAD_PATH.unshift(File.expand_path('.',__dir__))
require 'socket'
require 'hurley'
require 'pry'
require 'parser'
require 'path_response'
require 'game'

class Server
  attr_reader :tcp_server,
              :client,
              :shutdown,
              :request_count,
              :hello_count,
              :request_lines,
              :parser,
              :path_response,
              :game

  def initialize
    @tcp_server = TCPServer.new(9292)
    @request_count = 0
    @hello_count = 0
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
    handle_request
    increment_counters
    play_game
    send_response
    set_shutdown
    client.close
  end

  def handle_request
    get_request_lines
    parser.set_request(request_lines)
    print_request
    read_body
  end

  def play_game
    start_game if path == '/start_game'
    take_guess if path == '/game' && verb == 'POST'
  end

  def get_request_lines
    puts "Ready for a request"
    @request_lines = []
    while line = client.gets and !line.chomp.empty?
      request_lines << line.chomp
    end
  end

  def read_body
    if parser.content_length > 0 && verb == "POST"
      @request_lines << client.read(parser.content_length)
      parser.set_request(request_lines)
    end
  end

  def print_request
    puts "Got this request:"
    puts request_lines.inspect
  end

  def start_game
    @game = Game.new
  end

  def take_guess
    game.guess(parser.guess)
  end

  def increment_counters
    @request_count += 1 unless path == '/favicon.ico'
    @hello_count += 1 if path == '/hello'
  end

  def generate_response
    server_data = {request_count: request_count,
                   hello_count: hello_count,
                   word: parser.word,
                   diagnostics: generate_diagnostic,
                   game: game}
    path_response.path_finder(path, verb, server_data)
  end

  def send_response
    response = generate_response
    output = "<http><head></head><body>#{response}</body></html>"
    client.puts headers(output)
    client.puts output
  end

  def set_shutdown
    @shutdown = path == '/shutdown'
  end

  def path
    parser.path
  end

  def verb
    parser.verb
  end

  def headers(output)
    heads = ["http/1.1 200 ok",
      "date: #{Time.now.strftime('%a, %e %b %Y %H:%M:%S %z')}",
      "server: ruby",
      "content-type: text/html; charset=iso-8859-1",
      "content-length: #{output.length}\r\n\r\n"]
    heads = change_game_header(heads) if verb == 'POST' && path == "/game"
    heads.join("\r\n")
  end

  def change_game_header(heads)
    heads[0] = "http/1.1 301 Moved Permanently"
    heads.insert(1, "Location: http://127.0.0.1:9292/game")
  end

  def generate_diagnostic
    parser.generate_diagnostic
  end

end

if __FILE__ == $0
  serve = Server.new
  serve.run
end
