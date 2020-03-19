require "./lib/http_json"
require "lcsort"

# Normalizes call numbers so that they can be used for sorting and searching by ranges.
class CallnumberNormalizer
  def self.normalize_one(callnumber)
    clean = self.clean_callnumber(callnumber)
    return nil if clean == nil
    Lcsort.normalize(clean)
  end

  # Returns an array of objects with the original callnumber
  # and the normalized version. For example:
  #
  # normalize(["a 123", "bb 456 2016"])
  # => [<callnumber: "a 123", normalized: "a  12300">,
  #     <callnumber: "bb 456 2016", normalized: "bb 456">]
  def self.normalize_many(callnumbers)
    normalized = []
    callnumbers.each do |callnumber|
      norm = self.normalize_one(callnumber)
      normalized << OpenStruct.new(callnumber: callnumber, normalized: norm)
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
