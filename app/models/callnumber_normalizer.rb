require "./lib/http_json"

# Calls the callnumber normalize API to normalize callnumbers.
class CallnumberNormalizer
  def self.normalize_one(callnumber)
    normalized = self.normalize_many([callnumber])
    return nil if normalized.count == 0
    normalized[0][:normalized]
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
    api_url = ENV["NORMALIZE_API_URL"]
    raise "NORMALIZE_API_URL is not defined" if api_url == nil
    url = api_url + "/?callnumber=#{numbers.join(',')}"
    response = HttpUtil::HttpJson.get(URI.encode(url))
    response["result"]["items"].each do |item|
      normalized << OpenStruct.new(
        :callnumber => item["call_number"],
        :normalized => item["normalized_call_number"])
    end
    normalized
  rescue => e
    puts e
    []
  end

  def self.clean_callnumber(callnumber)
    return nil if callnumber.start_with?("Newspaper ")
    return nil if callnumber.gsub(/[^\w\s\.]/, "") != callnumber
    callnumber
  end
end
