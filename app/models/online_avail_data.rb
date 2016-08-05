class OnlineAvailData
  attr_reader :url, :label

  # url is 856 u
  # note is 856 z
  # materials is 856 z
  def initialize(url, note, materials)
    @url = url
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
