# -*- encoding : utf-8 -*-
#
class ReservesController < ApplicationController
  def search
    begin
      @course_num = params["course_num"]
      @instructor = params["instructor"]
      @course_name = params["course_name"]
      @no_courses_msg = nil
      reserves = Reserves.new
      @courses = reserves.courses_all()
      if @courses.count == 0
        @no_courses_msg = "No courses are available at this time. " +
          "See a librarian at the front desk for more information."
      end
    rescue StandardError => e
      Rails.logger.error("Course Reserves: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      @no_courses_msg = "Could not retrieve Course Reserves information"
      @courses = []
    end
    render
  end

  def show
    begin
      @classid = params[:classid]
      @classnumber = params[:classnumber]
      reserves = Reserves.new
      @materials = reserves.items_for_course(@classid)
      @page_title = "Reserves #{@materials.course.number_section}"
      render
    rescue StandardError => e
      @page_title = "Reserves #{@classnumber}"
      if e.class == JSON::ParserError && e.message.include?("not found")
        status = 404
        @not_found_title = "Course #{@classnumber} was not found"
        @not_found_msg = "There is no information for course #{@classnumber} (ID: #{@classid})"
      else
        Rails.logger.error("Course Reserves: #{e.message}")
        Rails.logger.error(e.backtrace.join("\n"))
        status = 500
        @not_found_title = "Error getting details for course #{@classnumber}"
        @not_found_msg = "Error getting information for course #{@classnumber} (ID: #{@classid})"
      end
      render "show_error", status: status
    end
  end
end
