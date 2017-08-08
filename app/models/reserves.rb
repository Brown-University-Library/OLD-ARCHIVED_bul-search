require "./lib/http_json.rb"

class Reserves
  def initialize
    @api_url = ENV["OCRA_API_URL"]
    raise "No value for OCRA_API_URL was found the environment" if @api_url == nil
  end

  def courses_by_course_num(course_num)
    # OCRA's API allows for partial matches of cours number and
    # section. For example "LITR 0100A" or "LITR 0100A S02"
    url = "#{@api_url}/coursesearch/#{CGI.escape(course_num.gsub(' ', ''))}"
    response = HttpUtil::HttpJson.get(url)
    courses = response.map {|x| ReservesCourse.from_hash(x)}
    courses.sort_by { |c| c.number_section }
  end

  def courses_by_instructor(instructor)
    # OCRA's API allows for partial matches on the instructor name.
    instructor = "" if instructor.blank?
    if instructor.first == "#"
      # search by instructor id, drop the #
      instructor = instructor[1..-1]
    end
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
    courses.sort_by { |c| c.number_section }
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
      course.semester = item["semester"]
      course.location = item["library"]
      course.instructor_id = item["instructorid"]
      course.instructor = item["instructor"]
      course.instructor_lastname = item["instructor_ln"]
      course.instructor_firstname = item["instructor_fn"]
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
      @online_url = "https://library.brown.edu/reserves/student/course/?classid=#{@course.classid}"
    end
  end
end

class ReservesBook
  attr_accessor :bib, :callno, :title, :author, :loan_term, :personal
  def self.from_hash(hash)
    rb = ReservesBook.new()
    if hash["bib"] && hash["bib"].length == 8 && hash["bib"][0] == "b"
      # only use the bib number if it looks like a bib number
      rb.bib = hash["bib"]
    end
    rb.callno = hash["callno"]
    rb.title = hash["title"]
    rb.author = hash["author"]
    rb.loan_term = hash["loan_term"]
    rb.personal = hash["personal"] # item is the personal copy of the professor
    rb
  end
end

class ReservesCourse
  attr_accessor :classid, :number, :section, :semester, :name, :location,
    :instructor, :instructor_id, :instructor_lastname, :instructor_firstname
  def self.from_hash(hash)
    rc = ReservesCourse.new()
    rc.classid = hash["classid"]
    rc.name = hash["name"]
    rc.number = hash["number"]
    rc.section = hash["section"]
    rc.instructor = hash["instructor"]
    rc.instructor_id = hash["instructorid"]
    rc.semester = hash["semester"]
    rc.location = hash["library"]
    rc
  end

  def number_section
    "#{number} #{section}".strip
  end

  def full_number
    full = number_section
    full += " " + semester if !semester.blank?
    full
  end

  def number_url
    number_section.gsub(" ", "-")
  end

  def instructor_search
    if instructor_id
      return "#" + instructor_id
    end

    if instructor_lastname || instructor_firstname
      # If we have the individual values search by those.
      return "#{instructor_lastname} #{instructor_firstname}".strip
    end

    # Otherwise do our best parsing the full instructor name
    tokens = instructor.split(" ")
    if tokens.count <= 2
      return instructor
    end

    has_middle_initial = tokens.count == 3 && tokens[1].strip.length == 1
    if has_middle_initial
      # Drop the middle initial
      return tokens.first + " " + tokens.last
    end

    # Our last hope, search by first name only.
    tokens.first
  end
end
