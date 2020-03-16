# -*- encoding : utf-8 -*-
#
require "./lib/http_json.rb"
class DashboardController < ApplicationController
  def index
    render
  end

  def show
    list_id = (params["id"] || 0).to_i
    @summary = EcoSummary.find_by_sierra_list(list_id)
    if @summary == nil
        render "show_empty"
        return
    end
    render
  end

  def new
    redirect_to dashboard_edit_url(id: "123")
  end

  def edit
    @data = OpenStruct.new(:id => params["id"])
    @edit_user = true
    render
  end

  def save
    redirect_to dashboard_query_url(id: "123")
  end

  def query
    @data = Dashboard.collection(params["id"])
    if @data == nil
      render "show_empty"
      return
    end
    render "show_local"
  end

  def details
    list_id = (params["id"] || 0).to_i
    summary = EcoSummary.find_by_sierra_list(list_id)
    if summary == nil
        render "show_empty"
        return
    end

    @rows = []
    @criteria = nil
    @sierra_list = summary.sierra_list
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
    else
      @criteria = "All"
      @rows = EcoDetails.where(sierra_list: @sierra_list)
    end

    if params["format"] == "tsv"
      send_data(EcoDetails.to_tsv(@rows), :filename => "sierra_list_#{list_id}.tsv", :type => "text/tsv")
      return
    end

    @rows = @rows.take(@limit)
    render "details"
  end
end
