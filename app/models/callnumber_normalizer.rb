require "./lib/http_json"
require "lcsort"

# Normalizes call numbers so that they can be used for sorting and searching by ranges.
class CallnumberNormalizer
  # Normalizes a single call number
  def self.normalize_one(callnumber)
    return nil if callnumber == nil
    Lcsort.normalize(callnumber)
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

  # Normalizes a range of call numbers and returns true if call numbers
  # represent a range.
  #
  # If instead of full call numbers we receive only the LC classification
  # (e.g. "HB" and "HB") on both ranges it also returns true.
  # Notice that we only support this if both ranges map to the same LC
  # classification.
  def self.normalize_range(cn_from, cn_to)
    cn_from = (cn_from || "").strip
    cn_to = (cn_to || "").strip

    norm_from = CallnumberNormalizer.normalize_one(cn_from)
    norm_to = CallnumberNormalizer.normalize_one(cn_to)
    if norm_from != nil && norm_to != nil
      # It's a typical LC range, e.g. "HB 123" to "HB 567"
      return true, norm_from, norm_to
    end

    norm_from = CallnumberNormalizer.lc_class(cn_from)
    norm_to = CallnumberNormalizer.lc_class(cn_to)
    if norm_from != nil && norm_to != nil && (norm_from == norm_to)
      # It's a single LC class, e.g. "HB" to "HB"
      return true, norm_from, norm_to
    end

    # Not a valid range
    return false, nil, nil
  end

  # Returns the "LC Classification" for the given call number
  # e.g. for "QA9.58 .D37 2008" it returns "QA"
  def self.lc_class(callnumber)
    return nil if callnumber == nil
    reg_ex = /^[A-Z]{1,3}/
    matches = reg_ex.match(callnumber.upcase)
    if matches != nil && matches.length == 1
      return matches[0].to_s
    end
    return nil
  end
end
