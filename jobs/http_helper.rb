require 'httpclient'

module HttpHelper
  def self.get(uri_string)
    client = HTTPClient.new
    if uri_string.start_with? "https"
      client.ssl_config.set_client_cert_file(ENV['HOME'] + '/dev/certs/personal.pem', ENV['HOME'] + '/dev/certs/personal.pem')
    end

    response = client.get uri_string
    response.content
  end

  def self.getProduct(uri_string)
    client = HTTPClient.new
    if uri_string.start_with? "https"
      client.ssl_config.set_client_cert_file(ENV['HOME'] + '/Downloads/client.crt', ENV['HOME'] + '/Downloads/client.crt')
    end

    response = client.get uri_string
    response.content
  end
end
