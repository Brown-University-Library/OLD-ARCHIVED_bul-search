# -*- encoding : utf-8 -*-
#
require "./lib/http_json.rb"
require "./app/presenters/dashboard_details_presenter.rb"

class DashboardController < ApplicationController
  def index
    @page_title = "Dashboard"
    @summaries = EcoSummary.all
    render
  end

  def show
    @summaries = EcoSummary.all
    id = (params["id"] || 0).to_i
    summary = EcoSummary.find(id)
    @page_title = summary.list_name
    @presenter = DashboardDetailsPresenter.new(summary, nil, nil, nil)
    @presenter.download_url = dashboard_details_url(id: id, format: 'tsv')
    render
  rescue ActiveRecord::RecordNotFound
    Rails.logger.error("Summary not found (#{id})")
    redirect_to dashboard_index_url()
  end

  def edit
    id = (params["id"] || 0).to_i
    @summary = EcoSummary.find(id)
    @page_title = summary.list_name
    @edit_user = true
    render
  rescue ActiveRecord::RecordNotFound
    Rails.logger.error("Summary not found (#{id})")
    redirect_to dashboard_index_url()
  end

  def details
    @summaries = EcoSummary.all

    id = (params["id"] || 0).to_i
    all = (params["all"] == "yes")
    max = all ? -1 : 1000
    rows = []
    count = 0
    summary = EcoSummary.find(id)
    @page_title = summary.list_name
    @presenter = nil

    range_id = (params["range_id"] || 0).to_i
    loc_code = (params["loc_code"] || "").strip
    ck_count = (params["ck"] || "").to_i

    if range_id > 0
      range = EcoRange.find(range_id)
      count, rows = EcoDetails.by_range(range, max)
      @presenter = DashboardDetailsPresenter.new(summary, range.name, count, rows)
      @presenter.from = range.from
      @presenter.to = range.to
      @presenter.download_url = dashboard_details_url(id: id, range_id: range_id, all: 'yes', format: 'tsv')
      @presenter.show_all_url = dashboard_details_url(id: id, range_id: range_id, all: 'yes')
    elsif loc_code != ""
      count, rows = EcoDetails.by_location(loc_code, summary.id, max)
      name = "Location #{Location.get_name(loc_code)} (#{loc_code})"
      @presenter = DashboardDetailsPresenter.new(summary, name, count, rows)
      @presenter.download_url = dashboard_details_url(id: id, loc_code: loc_code, all: 'yes', format: 'tsv')
      @presenter.show_all_url = dashboard_details_url(id: id, loc_code: loc_code, all: 'yes')
    elsif ck_count > 0
      count, rows = EcoDetails.by_usage(ck_count, summary.id, max)
      name = "Checked out #{ck_count} times"
      @presenter = DashboardDetailsPresenter.new(summary, name, count, rows)
      @presenter.download_url = dashboard_details_url(id: id, ck: ck_count, all: 'yes', format: 'tsv')
      @presenter.show_all_url = dashboard_details_url(id: id, ck: ck_count, all: 'yes')
    else
      count, rows = EcoDetails.by_summary(summary.id, max)
      name = max == -1 ? "All items" : "First #{max} items"
      @presenter = DashboardDetailsPresenter.new(summary, name, count, rows)
      @presenter.download_url = dashboard_details_url(id: id, all: 'yes', format: 'tsv')
      @presenter.show_all_url = dashboard_details_url(id: id, all: 'yes')
    end

    if params["format"] == "tsv"
      Rails.logger.info("Exporting TSV: #{@presenter.summary.list_name} - #{@presenter.name}, #{@presenter.count} records")
      send_data(EcoDetails.to_tsv(@presenter.rows), :filename => "dashboard_#{summary.id}.tsv", :type => "text/tsv")
      return
    end

    render "details"
  rescue ActiveRecord::RecordNotFound
    Rails.logger.error("Summary not found (#{id})")
    redirect_to dashboard_index_url()
  end
end
