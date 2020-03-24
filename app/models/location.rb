class Location < ActiveRecord::Base
  # Gets the location name from the cache because we do this too often.
  def self.get_name(code)
    return "" if code == nil || code.empty?
    location = location_info(code)
    if location == nil
      code.upcase
    else
      location.name
    end
  end

  def self.location_info(code)
    return Rails.cache.fetch("location_#{code}", expires_in: 2.minute) do
      begin
        find_by_code(code)
      rescue Exception => e
        Rails.logger.error "Location::LocationInfo(): Could not location from cache: #{e.to_s}"
        nil
      end
    end
  end
end
