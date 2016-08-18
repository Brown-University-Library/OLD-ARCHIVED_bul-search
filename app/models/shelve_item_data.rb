class ShelveItemData
  attr_reader :id, :callnumbers, :author, :title
  attr_accessor :highlight

  def initialize(id, callnumbers, author, title)
    @id = id
    @callnumbers = callnumbers || []
    @author = author || ""
    @title = title || ""
    @highlight = false
  end
end
