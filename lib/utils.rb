def get_hash_from_json(json)
  return MultiJson.load(json, symbolize_keys: true)
end

def get_ssl(url)
  uri = URI.parse(url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = false
  http.use_ssl = true if uri.scheme == "https"
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE if http.use_ssl?

  request = Net::HTTP::Get.new(uri.request_uri)

  return http.request(request).body
end

def get_key (key_string, hash)
  keys = key_string.split("/")
  keys.each do |key_value|
    if hash.kind_of?(Array)
      hash = hash[Integer(key_value)]
    else 
      hash = hash.find{|key, value| key[key_value]}[1]
    end
  end
  return hash
end
