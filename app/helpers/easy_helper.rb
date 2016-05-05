require 'cgi'

module EasyHelper
  def data_link(query)
    url_for :controller=>'easy', :action=> 'search', :q => query
  end
  def website_search(query)
    url_for :controller=>'libweb', :action=> 'search', :q => query
  end
  def catalog_record_url
    #This shouldn't be hard coded but couldn't find Blacklight documentation
    #at first pass.
    base = url_for :controller=>'catalog'
    return base + 'catalog/'
  end

  def escape_query query
    CGI.escape(query)
  end

  def worldcat_search(query)
    query = escape_query(query)
    return "http://worldcat.org.revproxy.brown.edu/search?&q=#{query}"
  end

  def summon_search(query)
    query = escape_query(query)
    return "http://brown.preview.summon.serialssolutions.com/#!/search?ho=t&fvf=ContentType,Journal%20Article,f%7CIsScholarly,true,f&l=en&q=#{query}"
  end

  def bdr_search(query)
    query = escape_query(query)
    return ENV["BDR_SEARCH_URL"] + "?q=#{query}"
  end

  def render_format_info_text(format)
    text = Constants::FORMAT[format]
    unless text.nil?
      info = text[:info]
      unless info.nil?
        render partial: "shared/info_box", locals: {:text => info}
      end
    end
  end

  def render_info_text(text)
    return nil unless !text.nil?
    render partial: "shared/info_box", locals: {:text => text}
  end

  def render_crazy_egg_code
    code = ENV['CRAZY_EGG_CODE']
    return nil unless !code.nil?
    js = <<-HTML
    <script type="text/javascript">
    setTimeout(function(){var a=document.createElement("script");
    var b=document.getElementsByTagName("script")[0];
    a.src=document.location.protocol+"//script.crazyegg.com/pages/scripts/#{code}.js?"+Math.floor(new Date().getTime()/3600000);
    a.async=true;a.type="text/javascript";b.parentNode.insertBefore(a,b)}, 1);
    </script>
    HTML
    render inline: js
  end

  def render_best_bet bet
    render partial: "best_bet", locals: bet
  end

  #
  #Link back to easySearch with the last search if available.
  #Returns a url string to the easy controller.
  def easy_search_link
    #Get the search from the history if it's there or from q param.
    query = get_last_easy_search || params[:q] || @current_search_session.query_params[:q] if @current_search_session.respond_to? :query_params
    if query.nil?
      return url_for :controller=>'easy', :action=> 'home'
    else
      return url_for :controller=>'easy', :action=> 'home', :q => query
    end
  end

  def get_last_easy_search
    session[:last_easy_search] || nil
  end

end
