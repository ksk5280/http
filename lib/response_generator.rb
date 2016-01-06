class ResponseGenerator
  attr_reader :responses, :data

  def initialize
    @responses = response_methods
  end

  def response_methods
    {'/hello' => :hello_response,
    '/datetime' => :datetime_response,
    '/request' => :request_response,
    '/shutdown' => :request_response,
    '/' => :diagnostics_response}
  end

  def generate_response(type, data_in)
    @data = data_in
    send(responses[type])
  end

  def hello_response
    "Hello, World! (#{data[:hello_count]})"
  end

  def datetime_response
    Time.now.strftime('%I:%M%p on %A, %B %-d, %Y')
  end

  def request_response
    "Total Requests: #{data[:request_count]}"
  end

  def diagnostics_response
    request_details = data[:request_details]
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
