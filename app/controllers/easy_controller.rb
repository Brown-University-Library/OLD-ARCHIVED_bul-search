

class EasyController < ApplicationController
  include Blacklight::Catalog
  include Blacklight::BlacklightHelperBehavior
  def home
    @easy_search = true
    query = params[:q]
    if query.blank?
      @has_query = false
    else
      @has_query = true
      @best_bet = get_best_bet(query)
    end
  end

  def search
    @search_result = Easy.new params[:source], params[:q]
    #Add search to history for search history page.
    s = Search.create(:query_params => params)
    add_to_search_history(s)
    #Set session variable with this query.
    set_last_easy_search(params[:q])
    render json: @search_result.to_json
  end

  def search_action_url
      url_for(:controller => 'easy', :action => 'home', :only_path => true)
  end

  def set_last_easy_search query
    session[:last_easy_search] = query
  end

  def get_best_bet query
    solr_url = ENV['BEST_BETS_SOLR_URL']
    solr = RSolr.connect :url => solr_url

    qp = {
        :wt=>"json",
        "q"=>"#{query}",
        "qt" => 'search',
    }

    response = solr.get 'search', :params => qp
    response[:response][:docs][0]
  end

end
