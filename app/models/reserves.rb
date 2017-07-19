require "./lib/http_json.rb"

class Reserves
  def initialize
    @api_url = ENV["OCRA_API_URL"]
    raise "No value for OCRA_API_URL was found the environment" if @api_url == nil
  end

  def courses_by_course_num(course_num)
    # OCRA's API allows for partial matches of cours number and
    # section. For example "LITR 0100A" or "LITR 0100A S02"
    url = "#{@api_url}/coursesearch/#{CGI.escape(course_num)}"
    response = HttpUtil::HttpJson.get(url)
    courses = response.map {|x| ReservesCourse.from_hash(x)}
  end

  def courses_by_instructor(instructor)
    # OCRA's API allows for partial matches on the instructor name.
    instructor = "" if instructor.blank?
    url = "#{@api_url}/instructor/#{CGI.escape(instructor)}"
    response = HttpUtil::HttpJson.get(url)
    courses = []
    response.each do |instructor|
      instructor["courses"].each do |c|
        course = ReservesCourse.from_hash(c)
        course.instructor = "#{instructor['lastname']}, #{instructor['firstname']}"
        courses << course
      end
    end
    courses
  end

  def items_for_course(id)
    # OCRA's API can take either the class id (e.g. 207) or
    # class number + section (e.g. "LITR 0100A S02"). In our
    # case id is always the class id.
    url = "#{@api_url}/reserves/#{id.to_i}"
    response = HttpUtil::HttpJson.get(url)
    if response.length == 1
      item = response[0]
      course = ReservesCourse.new()
      course.classid = item["classid"]
      course.number = item["number"]
      course.name = item["name"]
      course.section = item["section"]
      course.instructor = item["instructor"]
      course.semester = item["semester"]
      books = (item["books"] || []).map {|x| ReservesBook.from_hash(x)}
      materials = ReservesMaterials.new(course, books, item["on_panopto"], item["online_items"])
    else
      nil
    end
  end
end

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
      @online_url = "https://worfdev.services.brown.edu/ocra_dev/student/course/?classid=#{@course.classid}"
    end
  end
end

class ReservesBook
  attr_accessor :bib, :callno, :title, :author, :loan_term, :personal
  def self.from_hash(hash)
    rb = ReservesBook.new()
    rb.bib = hash["bib"]
    rb.callno = hash["callno"]
    rb.title = hash["title"]
    rb.author = hash["author"]
    rb.loan_term = hash["loan_term"]
    rb.personal = hash["personal"] # item is the personal copy of the professor
    rb
  end
end

class ReservesCourse
  attr_accessor :classid, :number, :section, :instructor, :semester, :name
  def self.from_hash(hash)
    rc = ReservesCourse.new()
    rc.classid = hash["classid"]
    rc.name = hash["name"]
    rc.number = hash["number"]
    rc.section = hash["section"]
    rc.instructor = hash["instructor"]
    rc.semester = hash["semester"]
    rc
  end

  def number_section
    if section.blank?
      number
    else
      number + " " + section
    end
  end

  def full_number
    full = number_section
    full += " " + semester if !semester.blank?
    full
  end

  def number_url
    number_section.gsub!(" ", "-")
  end
end
