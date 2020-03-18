require "./lib/http_json"
require "lcsort"

# Normalizes call numbers so that they can be used for sorting and searching by ranges.
class CallnumberNormalizer
  def self.normalize_one(callnumber, api = false)
    normalized = self.normalize_many([callnumber], api)
    return nil if normalized.count == 0
    normalized[0][:normalized]
  end

  # Returns an array of objects with the original callnumber
  # and the normalized version. For example:
  #
  # normalize(["a 123", "bb 456 2016"])
  # => [<callnumber: "a 123", normalized: "a  12300">,
  #     <callnumber: "bb 456 2016", normalized: "bb 456">]
  def self.normalize_many(callnumbers, api = false)
    if api
      return self.normalize_many_api(callnumbers)
    end
    self.normalize_many_gem(callnumbers)
  end

  # Normalizes an array of call numbers via the lcsort gem
  # (local Ruby call)
  def self.normalize_many_gem(callnumbers)
    numbers = callnumbers.map { |c| self.clean_callnumber(c)}.compact
    normalized = []
    numbers.each do |number|
      norm = Lcsort.normalize(number)
      normalized << OpenStruct.new(callnumber: number, normalized: norm)
    end
    normalized
  rescue => e
    puts e
    []
  end

  # Normalizes an array of call numbers via the API (remote HTTP call)
  def self.normalize_many_api(callnumbers)
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
