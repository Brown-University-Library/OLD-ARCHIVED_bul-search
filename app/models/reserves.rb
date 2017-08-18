class Reserves
  def initialize
    @api_url = ENV["OCRA_API_URL"]
    raise "No value for OCRA_API_URL was found the environment" if @api_url == nil
  end

  def cache_update()
    errors = []
    ocra = ReservesOcra.new
    courses = ocra.all_courses()
    if courses.count == 0
      # Don't update the cache if we couldn't connect to OCRA
      errors << "Could not fetch data from OCRA"
      return errors
    end

    # Deletes the courses in the cache and re-populate the table
    # with the courses from OCRA.
    ReservesCache.delete_all
    courses.each do |course|
      c = ReservesCache.new
      c.classid = course.classid
      c.name = course.name
      c.number = course.number
      c.section = course.section
      c.number_search = number_search(course.number, course.section)
      c.instructor = course.instructor
      c.instructorid = course.instructor_id
      c.semester = course.semester
      if !c.save()
        errors << "Could not save class #{course.classid}, #{course.name}."
      end
    end
    return errors
  end

  # number + section but without spaces or dashes
  def number_search(number = nil, section = nil)
    number ||= ""
    section ||= ""
    "#{number}#{section}".gsub(" ", "").gsub("-", "")
  end

  def courses_all()
    cache = ReservesCache.all
    cache.map {|x| ReservesCourse.from_cache(x)}
  end

  # Fetches courses by number from the cache
  def courses_by_course_num(course_num)
    # TODO: Move this ReservesCache
    where = "number_search like :number_search"
    param = {number_search: number_search(course_num) + "%"}
    cache = ReservesCache.where(where, param)
    cache.map {|x| ReservesCourse.from_cache(x)}
  end

  # Fetches courses by instructor from the cache
  def courses_by_instructor(instructor)
    # TODO: Move this ReservesCache
    if instructor.start_with?("#")
      where = "instructorid = :instructorid"
      param = {instructorid: instructor.strip[1..-1]}
    else
      where = "instructor like :instructor"
      param = {instructor: "%" + instructor.strip + "%"}
    end
    cache = ReservesCache.where(where, param)
    cache.map {|x| ReservesCourse.from_cache(x)}
  end

  # Fetches the details for a course from OCRA
  def items_for_course(id)
    ocra = ReservesOcra.new
    ocra.items_for_course(id)
  end
end
