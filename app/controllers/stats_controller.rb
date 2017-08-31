# -*- encoding : utf-8 -*-
#
class StatsController < ApplicationController
  def eds
    if !valid_user?
      render "stats_error", status: 401
    else
      # utc_offset = Time.now.strftime("%z").to_i / 100
      begin_date = Date.today.to_s + " 04:00:00"
      end_date = (Date.today + 1).to_s + " 04:00:00"
      @st = SearchesStats.new("eds", begin_date, end_date)
      render
    end
  end

  def valid_user?
    return false if current_user == nil
    user = "/" + current_user + "/"
    return (ENV["STAT_USERS"] || "").includes?(user)
  end
end
