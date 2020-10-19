class OnlineAvailData
  attr_reader :url, :label

  CLASSIC_JOSIAH_URL = "http://josiah.brown.edu/record="
  NEW_JOSIAH_URL = "http://search.library.brown.edu/catalog/"

  def initialize(url, text)
    if url.start_with?(CLASSIC_JOSIAH_URL)
      @url = url.gsub(CLASSIC_JOSIAH_URL, NEW_JOSIAH_URL)
    else
      @url = url
      if !@url.start_with?("http://") && !@url.start_with?("https://")
        @url = "http://#{@url}"
      end
    end
    if text == nil
      @label = "Available online"
    else
      @label = text
    end
  end
end
