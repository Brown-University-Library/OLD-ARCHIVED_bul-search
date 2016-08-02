class ItemData
  attr_accessor :barcode, :location_code, :bookplate_code

  def has_data?
    @barcode != nil || @loc_code != nil || @bookplate_code != nil
  end

  def to_s
    "#{@barcode}, #{@location_code}, #{@bookplate_code}"
  end

  def bookplate_url
    return nil if @bookplate_code == nil
    # TODO: Get url from database
    "http://library.brown.edu/bookplates/fund.php?account=#{@bookplate_code}"
  end

  def bookplate_display
    # TODO: Get display from database
    return nil if @bookplate_code == nil
    "#{@bookplate_code}"
  end

end
