# -*- encoding : utf-8 -*-
#
require "./lib/http_json.rb"
require "./app/presenters/dashboard_details_presenter.rb"

class DashboardController < ApplicationController
  def index
    edit_user = edit_user?
    @page_title = "Dashboard"
    @summaries = []
    @editors = editors()

    EcoSummary.all.each do |summary|
      if summary.public == 1
        @summaries << summary
        next
      end
      if edit_user && summary.created_by == safe_current_user
        @summaries << summary
        next
      end
    end

    @new_dashboard_url = ""
    if edit_user?
      @new_dashboard_url = dashboard_new_url()
    else
      "https://search.library.brown.edu/users/auth/shibboleth?target=" + dashboard_new_url()
    end

    Rails.logger.info("Show dashboard list for user #{safe_current_user}.")
    render
  end

  def show
    id = (params["id"] || 0).to_i
    summary = EcoSummary.find(id)
    if summary.public != 1 && summary.created_by != safe_current_user
      Rails.logger.error("User #{safe_current_user} does not have access to summary #{id}")
      render "error", status: 500
      return
    end
    Rails.logger.info("Show dashboard #{id} for user #{safe_current_user}.")
    @page_title = summary.list_name
    @presenter = DashboardDetailsPresenter.new(summary)
    @presenter.download_url = dashboard_details_url(id: id, format: 'tsv')
    @presenter.edit_user = edit_user?
    render
  rescue ActiveRecord::RecordNotFound
    Rails.logger.error("Summary not found (#{id})")
    redirect_to dashboard_index_url()
  end

  def edit
    if !edit_user?
        Rails.logger.error("User #{safe_current_user} does not have access to edit")
        render "error", status: 500
        return
    end
    id = (params["id"] || 0).to_i
    summary = EcoSummary.find(id)

    if summary.public != 1 && summary.created_by != safe_current_user
      Rails.logger.error("User #{safe_current_user} does not have access to edit summary #{id}")
      render "error", status: 500
      return
    end

    Rails.logger.info("Edit dashboard #{id} for user #{safe_current_user}.")
    @presenter = DashboardDetailsPresenter.new(summary)
    @presenter.edit_user = true
    @page_title = summary.list_name
    render
  rescue ActiveRecord::RecordNotFound
    Rails.logger.error("Summary not found (#{id})")
    redirect_to dashboard_index_url()
  end

  def delete
    if !edit_user?
      Rails.logger.error("User #{safe_current_user} does not have access to delete")
      render status: 400, :json => "{\"message\": \"User does not have access to delete\"}"
      return
    end

    id = (params["id"] || 0).to_i
    summary = EcoSummary.find(id)
    if summary.public != 1 && summary.created_by != safe_current_user
      Rails.logger.error("User #{safe_current_user} does not have access to delete summary #{id}")
      render status: 400, :json => "{\"message\": \"User does not have access to delete this summary\"}"
      return
    end

    Rails.logger.info("Delete dashboard #{id} by user #{safe_current_user}.")
    EcoSummary.delete(id)
    EcoRange.delete_all(eco_summary_id: id)
    # TODO: delete details
    render status: 200, :json => "{\"message\": \"deleted\"}"
  end

  def details
    id = (params["id"] || 0).to_i
    all = (params["all"] == "yes")
    max = all ? -1 : 1000
    rows = []
    count = 0
    summary = EcoSummary.find(id)
    if summary.public != 1 && summary.created_by != safe_current_user
      Rails.logger.error("User #{safe_current_user} does not have access to details for summary #{id}")
      render "error", status: 500
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
      Rails.logger.info("Show details (range) for dashboard #{id} for user #{safe_current_user}.")
    elsif loc_code != ""
      count, rows = EcoDetails.by_location(loc_code, summary.id, max)
      name = "Location #{Location.get_name(loc_code)} (#{loc_code})"
      @presenter = DashboardDetailsPresenter.new(summary, name, count, rows)
      @presenter.download_url = dashboard_details_url(id: id, loc_code: loc_code, all: 'yes', format: 'tsv')
      @presenter.show_all_url = dashboard_details_url(id: id, loc_code: loc_code, all: 'yes')
      Rails.logger.info("Show details (location) for dashboard #{id} for user #{safe_current_user}.")
    elsif ck_count > 0
      count, rows = EcoDetails.by_usage(ck_count, summary.id, max)
      name = "Checked out #{ck_count} times"
      @presenter = DashboardDetailsPresenter.new(summary, name, count, rows)
      @presenter.download_url = dashboard_details_url(id: id, ck: ck_count, all: 'yes', format: 'tsv')
      @presenter.show_all_url = dashboard_details_url(id: id, ck: ck_count, all: 'yes')
      Rails.logger.info("Show details (usage) for dashboard #{id} for user #{safe_current_user}.")
    else
      count, rows = EcoDetails.by_summary(summary.id, max)
      name = max == -1 ? "All items" : "First #{max} items"
      @presenter = DashboardDetailsPresenter.new(summary, name, count, rows)
      @presenter.download_url = dashboard_details_url(id: id, all: 'yes', format: 'tsv')
      @presenter.show_all_url = dashboard_details_url(id: id, all: 'yes')
      Rails.logger.info("Show details (all) for dashboard #{id} for user #{safe_current_user}.")
    end

    if params["format"] == "tsv"
      Rails.logger.info("Exporting TSV: #{@presenter.summary.list_name} - #{@presenter.name}, #{@presenter.count} records for user #{safe_current_user}")
      send_data(EcoDetails.to_tsv(@presenter.rows), :filename => "dashboard_#{summary.id}.tsv", :type => "text/tsv")
      return
    end

    @presenter.edit_user = edit_user?
    render "details"
  rescue ActiveRecord::RecordNotFound
    Rails.logger.error("Summary not found (#{id})")
    redirect_to dashboard_index_url()
  end

  def new
    if !edit_user?
      Rails.logger.error("User #{safe_current_user} does not have access to create new")
      render "error", status: 500
      return
    end
    summary = EcoSummary.new()
    summary.list_name = "#{safe_current_user}'s new list"
    summary.description = ""
    summary.status = "UPDATED"
    summary.created_at = Time.now
    summary.created_by = safe_current_user
    summary.public = 0
    summary.save
    Rails.logger.info("Created dashboard #{summary.id} for user #{safe_current_user}.")
    redirect_to dashboard_edit_url(id: summary.id)
  end

  def copy
    if !edit_user?
      Rails.logger.error("User #{safe_current_user} does not have access to create copy")
      render "error", status: 500
      return
    end

    id = (params["id"] || 0).to_i
    summary = EcoSummary.copy(id, safe_current_user)
    Rails.logger.info("Created dashboard #{summary.id} from #{id} for user #{safe_current_user}.")
    redirect_to dashboard_edit_url(id: summary.id)
  end

  def save
    if !edit_user?
      Rails.logger.error("User #{safe_current_user} does not have access to save")
      render "error", status: 500
      return
    end
    id = (params["id"] || 0).to_i
    summary = EcoSummary.find(id)

    if summary.public != 1 && summary.created_by != safe_current_user
      Rails.logger.error("User #{safe_current_user} does not have access to save summary #{id}")
      render "error", status: 500
      return
    end

    Rails.logger.info("Saved dashboard #{summary.id} for user #{safe_current_user}.")
    summary.save_from_request(params, safe_current_user)
    redirect_to dashboard_show_url(id: id)
  rescue ActiveRecord::RecordNotFound
    Rails.logger.error("Summary not found (#{id})")
    redirect_to dashboard_index_url()
  end

  private
    def editors()
      return [] if !edit_user?
      data = []
      (ENV["DASHBOARD_USERS"] || "").split("/").each do |user|
        if (user != "")
          data << user
        end
      end
      data
    end

    def safe_current_user
      if ENV["LOCALHOST"] == "true"
        return "josiah@localhost"
      end
      current_user
    end

    def edit_user?
      if ENV["LOCALHOST"] == "true"
          return true
      end
      return false if current_user == nil
      user = "/#{current_user}/"
      return (ENV["DASHBOARD_USERS"] || "").include?(user)
    end
end
