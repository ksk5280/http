class Parser
  attr_reader :request_lines

  def verb
    request_lines[0].split[0]
  end

  def path
    request_lines[0].split[1]
  end

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
    "Verb: #{verb}\n" \
    "Path: #{path}\n" \
    "Protocol: #{protocol}\n" \
    "Host: #{host}\n" \
    "Port: #{port}\n" \
    "Origin: #{origin}\n" \
    "Accept: #{accept}\n" \
    '</pre>'
  end

  def set_request(request_lines)
    @request_lines = request_lines
  end

end
