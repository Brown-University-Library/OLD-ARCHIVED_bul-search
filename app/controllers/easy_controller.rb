

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
    @search_result = Easy.new params[:q]
    #response.headers['Content-Type'] = 'text/javascript'
    render json: @search_result.to_json
    #body: @search_result.to_json, layout: false, content_type: "text/javascript"
  end

  def search_action_url
      url_for(:controller => 'easy', :action => 'home', :only_path => true)
  end

  def options_for_select
    return []
  end
end
