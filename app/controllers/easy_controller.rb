class EasyController < ApplicationController
  include Blacklight::Catalog
  include Blacklight::BlacklightHelperBehavior
  include ApplicationHelper # for trusted_ip?()

  def about
    @new_header = use_new_header()
    render "about"
  end

  def home
    @new_header = use_new_header()
    @format_stats = []
    @trusted_ip = trusted_ip?(request.remote_ip)
    @easy_search = true
    @query = params[:q]
    @has_query = false
    if @query.blank?
      # Render the landing page.
      @query = ""
      begin
        blacklight_config = Blacklight.default_configuration
        searcher = SearchCustom.new(blacklight_config)
        @format_stats = searcher.stats_by_format()
      rescue Exception => ex
        Rails.logger.error("Error getting format stats: #{ex}")
      end
      @hide_search_bar = (params["onesearch"] == "no") ? false : true
      @search_menu = (params["searchmenu"] == "yes")
      @skip_menu_to_id = "welcome"
      render "landing"
    else
      # Render the results page page.
      @has_query = true
      @best_bet = Easy.get_best_bet(@query)
      @skip_menu_to_id = "bentos"
      render "results"
    end
  end

  def search
    @new_header = use_new_header()
    beginTime = Time.now
    trusted_ip = trusted_ip?(request.remote_ip)
    guest_user = current_user == nil
    @search_result = Easy.new(params[:source], params[:q], guest_user, trusted_ip)
    endTime = Time.now
    elapsed_ms = (endTime - beginTime) * 1000.0
    save_search(params, elapsed_ms, trusted_ip, guest_user)
    #Set session variable with this query.
    set_last_easy_search(params[:q])
    @search_result = empty_set() if @search_result == nil
    render json: @search_result.to_json
  rescue StandardError => e
    Rails.logger.error e.message
    Rails.logger.error e.backtrace.join("\n")
    render json: empty_set().to_json, status: 500
  end

  def save_search(params, elapsed_ms, trusted_ip, guest_user)
    query_params = params
    query_params[:elapsed_ms] = elapsed_ms
    query_params[:trusted_ip] = trusted_ip
    query_params[:guest_user] = guest_user
    s = Search.create(:query_params => params)
    add_to_search_history(s)
  end

  def search_action_url
      url_for(:controller => 'easy', :action => 'home', :only_path => true)
  end

  def set_last_easy_search query
    session[:last_easy_search] = query
  end

  def not_found()
    @new_header = use_new_header()
    flash[:error] = "The page that you are looking for was not found"
    render "home", status: 404
  end

  def empty_set
    {docs: []}
  end
end
