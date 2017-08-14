class ReservesCourse
  attr_accessor :classid, :number, :section, :semester, :name, :location,
    :instructor, :instructor_id, :instructor_lastname, :instructor_firstname,
    :number_search

  def self.from_cache(cache)
    rc = ReservesCourse.new()
    rc.classid = cache.classid
    rc.name = cache.name
    rc.number = cache.number
    rc.section = cache.section
    rc.instructor = cache.instructor
    rc.instructor_id = cache.instructorid
    rc.semester = cache.semester
    rc.location = cache.library
    rc.number_search = cache.number_search
    rc
  end

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
