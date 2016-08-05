class ItemData
  attr_reader :barcode
  attr_accessor :location_code, :bookplate_code
  attr_writer :bookplate_url, :bookplate_display

  def initialize(barcode)
    if barcode == nil
      @barcode = nil
    else
      @barcode = barcode.gsub(" ", "")
    end
  end

  def bookplate_url
    @bookplate_url || ""
  end

  def bookplate_display
    @bookplate_display || ""
  end

  def to_s
    "#{@barcode}, #{@location_code}, #{@bookplate_code}"
  end
end
