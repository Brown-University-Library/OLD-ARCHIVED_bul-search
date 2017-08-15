require "./lib/http_json"

class Availability
  def initialize
    if ENV['AVAILABILITY_SERVICE'] == nil
      raise "No value for AVAILABILITY_SERVICE was found the environment"
    end
    @base_url = "https:#{ENV['AVAILABILITY_SERVICE']}"
  end

  # Returns the availability for the individual items
  # of a given BIB.
  #
  # For BIB records that have a lot of items the Availability API
  # returns only a small number of them. The API response includes
  # two values (has_more and more_link) to indicate whether there
  # are more items available and the query string that we can pass
  # to fetch them. At some point we might want to automatically
  # process this scenario and request the "more items" behind the
  # scenes. At this point we only get the default set of items
  # that the API returns.
  def get_items(bib)
    url = URI.encode("#{@base_url}#{bib}/")  # trailing / is required
    response = HttpUtil::HttpJson.get(url)
    items = []
    response["items"].each do |item|
      av_item = AvailabilityItem.new
      av_item.barcode = item["barcode"]
      av_item.callnumber = item["callnumber"]
      av_item.location = item["location"]
      av_item.map_url = item["map"]
      av_item.status = item["status"]
      shelf = item["shelf"] || {}
      av_item.level = shelf["floor"]
      av_item.aisle = shelf["aisle"]
      items << av_item
    end
    items
  rescue => e
    puts "Error fetching availabilty item information for #{bib}. \r\n#{e.message}"
    []
  end

  def self.get(base_url, bib)
    return nil if base_url == nil
    url = URI.encode("https:#{base_url}#{bib}/")  # trailing / is required
    response = HttpUtil::HttpJson.get(url)
  rescue => e
    puts "Error fetching availabilty information for #{bib}. \r\n#{e.message}"
    nil
  end
end
