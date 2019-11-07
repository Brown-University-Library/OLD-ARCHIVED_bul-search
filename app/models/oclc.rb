class Oclc
    # https://www.oclc.org/developer/develop/web-services/worldcat-search-api.en.html
    def search(q)
        url = "http://www.worldcat.org/webservices/catalog/search/opensearch?"
        url += "q=#{q}"
        url += "&wskey=#{ENV['OCLC_KEY']}"
        uri = URI.parse(url)
        http = Net::HTTP.new(uri.host, uri.port)
        request = Net::HTTP::Get.new(uri.request_uri)
        response = http.request(request)
        response.body
    end
end