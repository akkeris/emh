module CallServices
  def call_service(method)
    case method
    when :get then @response = RestClient.get(@full_url, @headers)
    when :post then @response = RestClient.post(@full_url, @data.to_json, @headers)
    when :delete then @response = RestClient.delete(@full_url, @headers)
    else
      puts "#{method} - is not a valid HTTP method call.".red
    end
    @response
  end

  def output_code(response)
    puts "Response HTTP Status Code: #{response_code(response)}".blue
  end

  def output_response(response, type = :json)
    puts "Response HTTP Response Body: \n#{response_body(response, type)}".blue
  end

  def response_code(response)
    response.code
  end

  def response_body(response, type = :json)
    case type
    when :non_json
      response.body
    else
      JSON.parse(response.body)
    end
  end

  def get_attribute(response, attribute)
    result = JSON.parse(response)
    result[attribute]
  end

  def check_response(service_name, response, expected_response, expected_response_code)
    check_response_code(service_name, response, expected_response_code)
    result = JsonCompare.get_diff(JSON.parse(expected_response.to_json), response_body(response))
    return true unless result != {}
    puts "Differencse between expected response and actual response:\n#{result}"
    raise "FATAL: #{service_name} failed.\nExpected:
      #{expected_response} \nRecieved: #{@response_body}".red
  end

  def check_text_response(service_name, response, expected_response)
    check_response_code(service_name, response, 200)
    result = @response_body.include? expected_response
    return true unless result == false
    puts "Difference between expected response and actual response:\n#{result}"
    raise "FATAL: #{service_name} failed.\nExpected: #{expected_response} \nRecieved: " \
      "#{@response_body}".red
  end

  def check_partial_response(service_name, response, expected_response)
    puts "Expected Response: #{expected_response}".blue
    puts "Actual Response: #{response}".blue
    return true unless expected_response != response
    raise "FATAL: #{service_name} failed.\nExpected:
      #{expected_response} \nActual: #{response}".red
  end

  def check_response_code(service_name, response, expected_response_code)
    return true unless response_code(response) != expected_response_code
    puts "FATAL: #{service_name} returned \nResponse code:
      #{response_code(response)} \nExpected: #{expected_response_code}".red
    exit raise 'SEE SCRIPT OUTPUT FOR FATAL ERRORS!!!'
  end
end
