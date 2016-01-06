module Parser
  def self.parse_request(request_lines)
    request_details = {}
    request_details["Verb"] = parse_verb(request_lines)
    request_details["Path"] = parse_path(request_lines)
    request_details["Protocol"] = parse_protocol(request_lines)
    request_details["Host"] = parse_host(request_lines)
    request_details["Port"] = parse_port(request_lines)
    request_details["Origin"] = parse_host(request_lines)
    request_details["Accept"] = parse_accept(request_lines)
    request_details
  end

  def self.parse_verb(request_lines)
    request_lines[0].split[0]
  end

  def self.parse_path(request_lines)
    request_lines[0].split[1]
  end

  def self.parse_protocol(request_lines)
    request_lines[0].split[2]
  end

  def self.parse_host(request_lines)
    request_lines.find { |line| line.start_with?('Host') }.split[1].split(':')[0]
  end

  def self.parse_port(request_lines)
    request_lines.find { |line| line.start_with?('Host') }.split(":")[2]
  end

  def self.parse_accept(request_lines)
    request_lines.find { |line| line.start_with?('Accept:') }[8..-1]
  end


end
