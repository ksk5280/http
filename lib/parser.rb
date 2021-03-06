class Parser
  attr_reader :request_lines

  def set_request(request_lines)
    @request_lines = request_lines
  end

  def verb
    request_lines[0].split[0]
  end

  def path
    request_lines[0].split[1].split('?')[0]
  end

  def word
    matched = request_lines[0].scan(/(?<=\=)\w+/)
    matched[0] if matched
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

  def body
    request_lines[-1]
  end

  def guess
    guess_in = body.scan(/(?<=guess\=)-*\d+/)
    if !guess_in.empty?
      guess_in[0].to_i
    end
  end

  def content_length
    cl_field = request_lines.find { |line| line.start_with?('Content-Length') }
    if cl_field
      cl_field.split[1].to_i
    else
      0
    end
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
end
