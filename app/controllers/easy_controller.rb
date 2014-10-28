

class EasyController < ApplicationController
  def home
    @easy_search = true
    if params[:q].blank?
        @has_query = false
    else
        @has_query = true
    end
  end

  def search
    @search_result = Easy.new params[:source], params[:q]
    #session[:last_easy_search] = params[:q]
    render json: @search_result.to_json
  end

  def search_action_url
      url_for(:controller => 'easy', :action => 'home', :only_path => true)
  end

  def options_for_select
    return []
  end
end
