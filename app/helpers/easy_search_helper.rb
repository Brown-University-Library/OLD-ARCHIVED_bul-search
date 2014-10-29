module EasySearchHelper

  #Link back to easySearch with the last search if available.
  #
  #Returns a url string to the easy controller.
  def easy_search_link
    #Get the search from the history if it's there or from q param.
    query = session[:last_easy_search] || params[:q] || @current_search_session.query_params[:q] if @current_search_session.respond_to? :query_params
    if query.nil?
      return url_for :controller=>'easy', :action=> 'home'
    else
      return url_for :controller=>'easy', :action=> 'home', :q => query
    end
  end

end