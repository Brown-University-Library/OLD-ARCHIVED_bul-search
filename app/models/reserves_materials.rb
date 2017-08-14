class ReservesMaterials
  attr_accessor :course, :books, :panopto_items, :online_items, :panopto_url, :online_url
  def initialize(course, books = [], panopto_items = 0, online_items = 0)
    @course = course
    @books = books
    @panopto_items = panopto_items.to_i
    @panopto_url = nil
    @online_items = online_items.to_i
    @online_url = nil
    if @panopto_items > 0
      # movies and streaming audio
      @panopto_url = "https://brown.hosted.panopto.com/"
    end
    if @online_items > 0
      @online_url = "https://library.brown.edu/reserves/student/course/?classid=#{@course.classid}"
    end
  end
end
