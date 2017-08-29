

class EasyController < ApplicationController
  include Blacklight::Catalog
  include Blacklight::BlacklightHelperBehavior
  include ApplicationHelper # for trusted_ip?()

  def home
    @easy_search = true
    @query = params[:q]
    @is_eds = ENV["JOURNALS_PROV"] == "eds"
    if @query.blank?
      @has_query = false
      @query = ''
    else
      @has_query = true
      @best_bet = Easy.get_best_bet(@query)
    end
  end

  def search
    beginTime = Time.now
    trusted_ip = trusted_ip?(request.remote_ip)
    guest_user = current_user == nil
    @search_result = Easy.new(params[:source], params[:q], guest_user, trusted_ip)
    endTime = Time.now
    elapsed_ms = (endTime - beginTime) * 1000.0
    save_search(params, elapsed_ms)
    #Set session variable with this query.
    set_last_easy_search(params[:q])
    @search_result = empty_set() if @search_result == nil
    render json: @search_result.to_json
  rescue StandardError => e
    Rails.logger.error e.message
    Rails.logger.error e.backtrace.join("\n")
    render json: empty_set().to_json
  end

  def save_search(params, elapsed_ms)
    query_params = params
    query_params[:elapsed_ms] = elapsed_ms
    s = Search.create(:query_params => params)
    add_to_search_history(s)
  end

  def search_action_url
      url_for(:controller => 'easy', :action => 'home', :only_path => true)
  end

  def set_last_easy_search query
    session[:last_easy_search] = query
  end

  def empty_set
    {docs: []}
  end
end
