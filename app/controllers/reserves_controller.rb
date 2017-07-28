# -*- encoding : utf-8 -*-
#
class ReservesController < ApplicationController
  def search
    begin
      @course_num = params["course_num"]
      @instructor = params["instructor"]
      @no_courses_msg = nil
      if !@course_num.blank?
        reserves = Reserves.new
        @courses = reserves.courses_by_course_num(@course_num)
        if @courses.count == 0
          @no_courses_msg = 'No courses were found for course #' + @course_num
        end
      else
        reserves = Reserves.new
        @courses = reserves.courses_by_instructor(@instructor)
        if @courses.count == 0
          @no_courses_msg = 'No courses were found for instructor ' + @instructor
        end
      end
    rescue StandardError => e
      Rails.logger.error("Course Reserves API: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      @no_courses_msg = "Could not retrieve Course Reserves information"
      @courses = []
    end
    render
  end

  def show
    @classid = params[:classid]
    reserves = Reserves.new
    @materials = reserves.items_for_course(@classid)
  end
end
