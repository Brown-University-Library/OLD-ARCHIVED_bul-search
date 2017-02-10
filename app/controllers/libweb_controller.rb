# Handles searches within the Library web site
# through Google Custom Search Engine (CSE)
# https://cse.google.com/
class LibwebController < ApplicationController

    def search
      @libweb_search = true
      if params[:q].blank?
        @has_query = false
      else
        @has_query = true
      end
    end

    def search_action_url
      url_for(:controller => 'libweb', :action => 'search', :only_path => true)
    end
end
