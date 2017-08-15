class AvailabilityItem
  attr_accessor :barcode, :callnumber, :location, :map_url, :status,
    :level, :aisle

  def location_text
    if location == nil
      level_aisle_text
    else
      if level_aisle_text == ""
        location
      else
        "#{location} -- #{level_aisle_text}"
      end
    end
  end

  def level_aisle_text
    case
    when level == nil && aisle == nil
      ""
    when level == nil && aisle != nil
      "Aisle #{aisle}"
    when level != nil && aisle == nil
      "Level #{level}"
    else
      "Level #{level}, Aisle #{aisle}"
    end
  end
end
