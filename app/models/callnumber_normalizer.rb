require "./lib/http_json"

class CallnumberNormalizer

  NORMALIZE_API_URL = "http://worfdev.services.brown.edu/services/call_number/v1"

  def self.normalize_one(callnumber)
    number = self.clean_callnumber(callnumber)
    return nil if number == nil
    url = NORMALIZE_API_URL + "/?callnumber=#{number}"
    response = HttpUtil::HttpJson.get(url)
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
  def self.normalize_many(callnumbers)
    numbers = callnumbers.map { |c| self.clean_callnumber(c)}.compact
    normalized = []
    url = NORMALIZE_API_URL + "/?callnumber=#{numbers.join(',')}"
    response = HttpUtil::HttpJson.get(url)
    response["result"]["items"].each do |item|
      normalized << OpenStruct.new(
        :callnumber => item["call_number"],
        :normalized => item["normalized_call_number"])
    end
    normalized
  end

  def self.clean_callnumber(callnumber)
    return nil if callnumber.start_with?("Newspaper ")
    return nil if callnumber.gsub(/[^\w\s\.]/, "") != callnumber
    callnumber
  end
end
