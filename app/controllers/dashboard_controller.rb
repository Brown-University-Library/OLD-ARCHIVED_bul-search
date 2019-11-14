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
    when "fund"
      if params["value"] == "(none)"
        @criteria = "where there is no fund code (limited to first #{@limit} rows)"
        @rows = EcoDetails.where(sierra_list: @sierra_list, fund_code: "")
      else
        @criteria = "where fund code is #{params["value"]} (limited to first #{@limit} rows)"
        @rows = EcoDetails.where(sierra_list: @sierra_list, fund_code: params["value"])
      end
    end
    @rows = @rows.take(@limit)
    render "details"
  end
end
