# -*- encoding : utf-8 -*-
#
require "./lib/http_json.rb"
class DashboardController < ApplicationController
  def index
    @summaries = EcoSummary.all
    render
  end

  def show
    id = (params["id"] || 0).to_i
    @summary = EcoSummary.find(id)
    render
  rescue ActiveRecord::RecordNotFound
    @summaries = EcoSummary.all
    render "show_empty"
  end

  def edit
    id = (params["id"] || 0).to_i
    @summary = EcoSummary.find(id)
    @edit_user = true
    render
  rescue ActiveRecord::RecordNotFound
    @summaries = EcoSummary.all
    render "show_empty"
  end

  def details
    id = (params["id"] || 0).to_i
    summary = EcoSummary.find(id)

    @rows = []
    @criteria = nil
    @sierra_list = summary.sierra_list
    @limit = 5000
    case params["key"]
    when "cn"
      @criteria = "where call number is #{params["value"]} (limited to first #{@limit} rows)"
      @rows = EcoDetails.where("sierra_list = ? AND callnumber_norm LIKE ?", summary.id, params["value"].downcase + "%")
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
      @rows = EcoDetails.where(eco_summary_id: summary.id)
    end

    if params["format"] == "tsv"
      send_data(EcoDetails.to_tsv(@rows), :filename => "sierra_list_#{list_id}.tsv", :type => "text/tsv")
      return
    end

    @rows = @rows.take(@limit)
    render "details"
  rescue ActiveRecord::RecordNotFound
    @summaries = EcoSummary.all
    render "show_empty"
  end
end
