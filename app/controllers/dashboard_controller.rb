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

    range_id = (params["range_id"] || 0).to_i
    if range_id > 0
      range = EcoRange.find(range_id)
      @data = {
        summary: summary,
        from: range.from,
        to: range.to,
        name: range.name,
        count: range.count,
        rows: EcoDetails.where(eco_summary_id: summary.id, eco_range_id: range_id)
      }
      render "details_range"
      return
    end

    @data = {
      summary: summary,
      rows: [],
      criteria: nil,
      limit: 5000
    }

    rows = []
    case params["key"]
    when "loc"
      @data[:criteria] = "where location is #{params["value"]} (limited to first #{@limit} rows)"
      rows = EcoDetails.where(eco_summary_id: summary.id, location_code: params["value"])
    when "ck"
      @data[:criteria] = "where checkout count is #{params["value"]} (limited to first #{@limit} rows)"
      rows = EcoDetails.where(eco_summary_id: summary.id, checkout_total: params["value"])
    when "fund"
      # todo
    else
      @data[:criteria] = "All"
      rows = EcoDetails.where(eco_summary_id: summary.id)
    end

    @data[:rows] = rows.take(@data[:limit])
    if params["format"] == "tsv"
      send_data(EcoDetails.to_tsv(@rows), :filename => "dashboard_#{summary.id}.tsv", :type => "text/tsv")
      return
    end

    render "details"
  rescue ActiveRecord::RecordNotFound
    @summaries = EcoSummary.all
    render "show_empty"
  end
end
