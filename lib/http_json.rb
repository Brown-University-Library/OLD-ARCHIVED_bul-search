module HttpUtil
  class HttpJson
    def self.get(url, headers = [])
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      if url.start_with?("https://")
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      request = Net::HTTP::Get.new(uri.request_uri)
      request.add_field("Content-Type", "application/json")
      request.add_field("Accept", "application/json")
      headers.each do |header|
        request.add_field(header[:key], header[:value])
      end
      response = http.request(request)
      JSON.parse(response.body)
    end

    def self.post(url, payload)
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      if url.start_with?("https://")
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      request = Net::HTTP::Post.new(uri.request_uri)
      request.add_field("Content-Type", "application/json")
      request.add_field("Accept", "application/json")
      request.body = payload
      response = http.request(request)
      JSON.parse(response.body)
    end
  end
end
