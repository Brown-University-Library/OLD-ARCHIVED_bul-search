class OnlineAvailData
  attr_reader :url, :label

  CLASSIC_JOSIAH_URL = "http://josiah.brown.edu/record="
  NEW_JOSIAH_URL = "http://search.library.brown.edu/catalog/"

  # url is 856 u
  # note is 856 z
  # materials is 856 z
  def initialize(url, note, materials)
    if url.start_with?(CLASSIC_JOSIAH_URL)
      @url = url.gsub(CLASSIC_JOSIAH_URL, NEW_JOSIAH_URL)
    else
      @url = url
      if !@url.start_with?("http://") && !@url.start_with?("https://")
        @url = "http://#{@url}"
      end
    end
    if note == nil && materials == nil
      @label = "Available online"
    elsif note == nil && materials != nil
      @label = materials
    elsif note != nil && materials == nil
      @label = note
    else
      @label = "#{note} (#{materials})"
    end
  end
end
