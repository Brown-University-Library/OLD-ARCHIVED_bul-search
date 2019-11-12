# -*- encoding : utf-8 -*-
#
require "./lib/http_json.rb"
class DashboardController < ApplicationController
  def index
    render
  end

  def show
    @info = EcoDetails.summary("ECON")
    if @info == nil
        render text: "Invalid subject"
        return
    end
    render
  end

  def details
    @rows = []
    @criteria = nil
    @sierra_list = 334
    @limit = 5000
    case params["key"]
    when "cn"
      @criteria = "where call number is #{params["value"]} (limited to first #{@limit} rows)"
      @rows = EcoDetails.where("sierra_list = ? AND callnumber_norm LIKE ?", @sierra_list, params["value"].downcase + "%")
    when "loc"
      @criteria = "where location is #{params["value"]} (limited to first #{@limit} rows)"
      @rows = EcoDetails.where(sierra_list: @sierra_list, location_code: params["value"])
    when "ck"
      @criteria = "where checkout count is #{params["value"]} (limited to first #{@limit} rows)"
      @rows = EcoDetails.where(sierra_list: @sierra_list, checkout_total: params["value"])
    end
    @rows = @rows.take(@limit)
    render "details"
  end

  # private

  #   def sierra_data(subject)
  #       Rails.cache.fetch("dashboard_#{subject}", expires_in: 1.day) do
  #           url = ENV["BIB_UTILS_SERVICE"] + "/collection/details?subject=#{subject}"
  #           Rails.logger.info("Loading data from bibService #{url}")
  #           HttpUtil::HttpJson.get(url, [], 300)
  #       end
  #   end

  #   def to_tsv(data)
  #     header = data[0].keys.join("\t")
  #     tsv = header + "\tJosiahLink\r\n"
  #     data.each do |row|
  #       values = []
  #       row.keys.each do |key|
  #         values << row[key]
  #       end
  #       values << "http://search.library.brown.edu/catalog/#{row['BibRecordNum']}"
  #       tsv += values.join("\t") + "\r\n"
  #     end
  #     tsv
  #   end
end
