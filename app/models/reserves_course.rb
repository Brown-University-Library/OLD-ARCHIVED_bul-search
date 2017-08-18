class ReservesCourse
  attr_accessor :classid, :number, :section, :semester, :name, :location,
    :instructor, :instructor_id, :number_search

  def initialize
    @lib_guide = nil
    @subject_guide = nil
  end

  # When we read the data from the SQL table
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

  # When we get the data from the OCRA API directly.
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
    cache = ReservesCache.find_by_classid(rc.classid)
      if cache
      # Get these values from the cache
      rc.number_search = cache.number_search
      rc.instructor = cache.instructor
    end
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
    "#{number}".strip.gsub(" ", "-")
  end

  def number_section_url
    number_section.gsub(" ", "-")
  end

  def lib_guide_url
    @lib_guide ||= begin
      Libguides.lib_guide(number_search) || ""
    end
    return nil if @lib_guide == ""
    @lib_guide
  end

  def subject_guide_url
    @subject_guide ||= begin
      Libguides.subject_guide(number_search) || ""
    end
    return nil if @subject_guide == ""
    @subject_guide
  end
end
