require "./lib/http_json"

class CallnumberNormalizer
  NORMALIZE_API_URL = "http://worfdev.services.brown.edu/services/call_number/v1"

  def self.normalize_one(callnumber)
    url = NORMALIZE_API_URL + "/?callnumber=#{callnumber}"
    response = HttpUtil::HttpJson.get(url)
    sleep(0.25) #throttle
    response["result"]["items"].each do |item|
      if item["call_number"] == callnumber
        return item["normalized_call_number"]
      end
    end
    nil
  end

  # Returns an array of objects with the original callnumber
  # and the normalized version. For example:
  #
  # normalize(["a 123", "bb 456 2016"])
  # => [<callnumber: "a 123", normalized: "a  12300">,
  #     <callnumber: "bb 456 2016", normalized: "bb 456">]
  def self.normalize(callnumbers)
    normalized = []
    url = NORMALIZE_API_URL + "/?callnumber=#{callnumbers.join(',')}"
    response = HttpUtil::HttpJson.get(url)
    sleep(0.25) #throttle
    response["result"]["items"].each do |item|
      normalized << OpenStruct.new(
        :callnumber => item["call_number"],
        :normalized => item["normalized_call_number"])
    end
    normalized
  end
end
