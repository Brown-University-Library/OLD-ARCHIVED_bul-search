# -*- encoding : utf-8 -*-
#
require "./lib/http_json.rb"
require "./app/presenters/dashboard_details_presenter.rb"

class DashboardController < ApplicationController
  def index
    @new_header = use_new_header()
    @page_title = "Dashboard"
    @editors = EcoSummary.editors(current_user)

    @summaries = []
    EcoSummary.all.each do |summary|
      if summary.can_view?(current_user)
        @summaries << summary
      end
    end

    @new_dashboard_url = ""
    if EcoSummary.edit_user?(current_user)
      @new_dashboard_url = dashboard_new_url()
    else
      @new_dashboard_url = "https://search.library.brown.edu/users/auth/shibboleth?target=" + dashboard_new_url()
    end

    Rails.logger.info("Show dashboard list for user #{current_user}.")
    render
  end

  def show
    @new_header = use_new_header()
    id = (params["id"] || 0).to_i
    summary = EcoSummary.find(id)
    if summary.can_view?(current_user)
      Rails.logger.info("Show dashboard #{id} for user #{current_user}.")
      @bootstrap_tabs = true
      @page_title = summary.list_name
      @presenter = DashboardDetailsPresenter.new(summary)
      @presenter.download_url = dashboard_details_url(id: id, format: 'tsv')
      @presenter.edit_user = summary.can_edit?(current_user)
      render
    else
      Rails.logger.error("User #{current_user} does not have access to summary #{id}")
      render "error", status: 500
    end
  rescue ActiveRecord::RecordNotFound
    Rails.logger.error("Summary not found (#{id})")
    redirect_to dashboard_index_url()
  end

  def edit
    @new_header = use_new_header()
    id = (params["id"] || 0).to_i
    summary = EcoSummary.find(id)
    if summary.can_edit?(current_user)
      Rails.logger.info("Edit dashboard #{id} for user #{current_user}.")
      @page_title = summary.list_name
      @presenter = DashboardDetailsPresenter.new(summary)
      @presenter.edit_user = true
      @presenter.can_delete = summary.can_delete?(current_user)
      render
    else
      Rails.logger.error("User #{current_user} does not have access to edit summary #{id}")
      render "error", status: 500
    end
  rescue ActiveRecord::RecordNotFound
    Rails.logger.error("Summary not found (#{id})")
    redirect_to dashboard_index_url()
  end

  def delete
    @new_header = use_new_header()
    id = (params["id"] || 0).to_i
    summary = EcoSummary.find(id)
    if summary.can_delete?(current_user)
      Rails.logger.info("Delete dashboard #{id} by user #{current_user}.")
      EcoSummary.delete(id)
      EcoRange.delete_all(eco_summary_id: id)
      # TODO: delete details
      render status: 200, :json => "{\"message\": \"deleted\"}"
    else
      Rails.logger.error("User #{current_user} does not have access to delete summary #{id}")
      render status: 400, :json => "{\"message\": \"User does not have access to delete this summary\"}"
    end
  rescue ActiveRecord::RecordNotFound
    Rails.logger.error("Summary not found (#{id})")
    redirect_to dashboard_index_url()
  end

  def details
    @new_header = use_new_header()
    id = (params["id"] || 0).to_i
    all = (params["all"] == "yes")
    max = all ? -1 : 1000
    rows = []
    count = 0
    summary = EcoSummary.find(id)
    if !summary.can_view?(current_user)
      Rails.logger.error("User #{current_user} does not have access to details for summary #{id}")
      render "error", status: 500
      return
    end

    if params["format"] == "tsv"
      # Return data for this collection as TSV (notice that we use the
      # pre-generated file with all the data, regardless of current filter)
      Rails.logger.info("Exporting TSV: #{summary.list_name} for user #{current_user}")
      send_data(File.read(summary.filename_tsv()), :filename => "dashboard_#{summary.id}.tsv", :type => "text/tsv")
      return
    end

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
      Rails.logger.info("Show details (range) for dashboard #{id} for user #{current_user}.")
    elsif loc_code != ""
      count, rows = EcoDetails.by_location(loc_code, summary.id, max)
      name = "Location #{Location.get_name(loc_code)} (#{loc_code})"
      @presenter = DashboardDetailsPresenter.new(summary, name, count, rows)
      @presenter.download_url = dashboard_details_url(id: id, loc_code: loc_code, all: 'yes', format: 'tsv')
      @presenter.show_all_url = dashboard_details_url(id: id, loc_code: loc_code, all: 'yes')
      Rails.logger.info("Show details (location) for dashboard #{id} for user #{current_user}.")
    elsif ck_count > 0
      count, rows = EcoDetails.by_usage(ck_count, summary.id, max)
      name = "Checked out #{ck_count} times"
      @presenter = DashboardDetailsPresenter.new(summary, name, count, rows)
      @presenter.download_url = dashboard_details_url(id: id, ck: ck_count, all: 'yes', format: 'tsv')
      @presenter.show_all_url = dashboard_details_url(id: id, ck: ck_count, all: 'yes')
      Rails.logger.info("Show details (usage) for dashboard #{id} for user #{current_user}.")
    else
      count, rows = EcoDetails.by_summary(summary.id, max)
      name = max == -1 ? "All items" : "First #{max} items"
      @presenter = DashboardDetailsPresenter.new(summary, name, count, rows)
      @presenter.download_url = dashboard_details_url(id: id, all: 'yes', format: 'tsv')
      @presenter.show_all_url = dashboard_details_url(id: id, all: 'yes')
      Rails.logger.info("Show details (all) for dashboard #{id} for user #{current_user}.")
    end

    @presenter.edit_user = EcoSummary.edit_user?(current_user)
    render "details"
  rescue ActiveRecord::RecordNotFound
    Rails.logger.error("Summary not found (#{id})")
    redirect_to dashboard_index_url()
  end

  def new
    @new_header = use_new_header()
    if EcoSummary.can_new?(current_user)
      summary = EcoSummary.new_for_user(current_user)
      Rails.logger.info("Created dashboard #{summary.id} for user #{current_user}.")
      redirect_to dashboard_edit_url(id: summary.id)
    else
      Rails.logger.error("User #{current_user} does not have access to create new")
      render "error", status: 500
    end
  end

  def copy
    @new_header = use_new_header()
    if EcoSummary.edit_user?(current_user)
      id = (params["id"] || 0).to_i
      summary = EcoSummary.copy(id, current_user)
      Rails.logger.info("Created dashboard #{summary.id} from #{id} for user #{current_user}.")
      redirect_to dashboard_edit_url(id: summary.id)
    else
      Rails.logger.error("User #{current_user} does not have access to create copy")
      render "error", status: 500
    end
  end

  def save
    @new_header = use_new_header()
    id = (params["id"] || 0).to_i
    summary = EcoSummary.find(id)
    if summary.can_edit?(current_user)
      Rails.logger.info("Saved dashboard #{summary.id} for user #{current_user}.")
      summary.save_from_request(params, current_user)
      redirect_to dashboard_show_url(id: id)
    else
      Rails.logger.error("User #{current_user} does not have access to save summary #{id}")
      render "error", status: 500
    end
  rescue ActiveRecord::RecordNotFound
    Rails.logger.error("Summary not found (#{id})")
    redirect_to dashboard_index_url()
  end
end
