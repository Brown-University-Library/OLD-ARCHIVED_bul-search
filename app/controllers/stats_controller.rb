# -*- encoding : utf-8 -*-
#
class StatsController < ApplicationController
  def server
    result = {}
    solr_url = ENV["SOLR_URL"]
    master_token = ENV["SOLR_URL_MASTER_TOKEN"]
    if solr_url.include?(master_token)
      result[:solr] = "master"
    else
      result[:solr] = "reader"
    end
    result[:s7] = solr_url.include?("josiah7")
    render :json => result
  end

  def solr_master
    result = {}
    solr_url = ENV["SOLR_URL_WRITE"]
    solr = SolrQuery.new(Blacklight.default_configuration, solr_url)
    response, docs = solr.search("blue", {})
    if docs.count == 0
      result["status"] = "Error"
      result["message"] = "No records were found"
    else
      result["status"] = "OK"
    end
    render json: result
  rescue => ex
    Rails.logger.error("Error validating Solr: #{ex}")
    result["status"] = "Error"
    result["message"] = "Could not validate master Solr"
    render json: result
  end

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

  private
    def valid_user?
      return false if current_user == nil
       user = "/#{current_user}/"
       return (ENV["STAT_USERS"] || "").include?(user)
     end
end
