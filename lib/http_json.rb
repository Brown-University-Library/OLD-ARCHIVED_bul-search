module HttpUtil
  class HttpJson
    def self.get(url)
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      if url.start_with?("https://")
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)
      # if response.code == "200"
      #   json = JSON.parse(response.body)
      # else
      #   json = {
      #     http_status: response.code,
      #     http_message: response.message,
      #     http_body: response.body
      #   }
      # end
      # json
      JSON.parse(response.body)
    end
  end
end
