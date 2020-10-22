class OnlineAvailData
  attr_reader :url, :label

  CLASSIC_JOSIAH_URL = "http://josiah.brown.edu/record="
  NEW_JOSIAH_URL = "http://search.library.brown.edu/catalog/"

  def initialize(url, note, materials = nil)
    if url.start_with?(CLASSIC_JOSIAH_URL)
      @url = url.gsub(CLASSIC_JOSIAH_URL, NEW_JOSIAH_URL)
    else
      @url = url
      if !@url.start_with?("http://") && !@url.start_with?("https://")
        @url = "http://#{@url}"
      end
    end
    @label = safe_concat(note, materials)
  end

  def safe_concat(note, materials)
    case
    when note == nil && materials == nil
      "Available online"
    when note == nil && materials != nil
      materials
    when note != nil && materials == nil
      note
    else
      "#{note} (#{materials})"
    end
  end
end
