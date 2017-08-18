require "./lib/http_json.rb"

class ReservesOcra
  def initialize
    @api_url = ENV["OCRA_API_URL"]
    raise "No value for OCRA_API_URL was found the environment" if @api_url == nil
  end

  def all_courses()
    url = "#{@api_url}/coursesearch/"
    response = HttpUtil::HttpJson.get(url)
    courses = response.map {|x| ReservesCourse.from_hash(x)}
    courses.sort_by { |c| c.number_section }
  end

  def items_for_course(id)
    # OCRA's API can take either the class id (e.g. 207) or
    # class number + section (e.g. "LITR 0100A S02"). In our
    # case is always the class id.
    url = "#{@api_url}/reserves/#{id.to_i}"
    response = HttpUtil::HttpJson.get(url)
    if response.length == 1
      item = response[0]
      course = ReservesCourse.from_hash(item)
      books = (item["books"] || []).map {|x| ReservesBook.from_hash(x)}
      materials = ReservesMaterials.new(course, books, item["on_panopto"], item["online_items"])
    else
      nil
    end
  end

  # Deprecated, we run searches from the cache rather than the API now.
  # def courses_by_course_num(course_num)
  #   # Dashes are not common in course numbers, but we display course numbers
  #   # with dashes in the URL and therefore users might copy and paste them
  #   # in the search box. Hence, we account for them here.
  #   search_value = course_num || ""
  #   search_value = search_value.gsub("-", " ").strip
  #
  #   # OCRA's API allows for partial matches of cours number and
  #   # section. For example "LITR 0100A" or "LITR 0100A S02"
  #   url = "#{@api_url}/coursesearch/#{CGI.escape(search_value)}"
  #   response = HttpUtil::HttpJson.get(url)
  #   courses = response.map {|x| ReservesCourse.from_hash(x)}
  #   courses.sort_by { |c| c.number_section }
  # end

  # Deprecated, we run searches from the cache rather than the API now.
  # def courses_by_instructor(instructor)
  #   # OCRA's API allows for partial matches on the instructor name.
  #   instructor = "" if instructor.blank?
  #   if instructor.first == "#"
  #     # search by instructor id, drop the #
  #     instructor = instructor[1..-1]
  #   end
  #   url = "#{@api_url}/instructor/#{CGI.escape(instructor)}"
  #   response = HttpUtil::HttpJson.get(url)
  #   courses = []
  #   response.each do |instructor|
  #     instructor["courses"].each do |c|
  #       course = ReservesCourse.from_hash(c)
  #       course.instructor = "#{instructor['lastname']}, #{instructor['firstname']}"
  #       courses << course
  #     end
  #   end
  #   courses.sort_by { |c| c.number_section }
  # end
end
