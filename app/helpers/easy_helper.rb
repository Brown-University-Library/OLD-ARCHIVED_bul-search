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
  def worldcat_search(query)
    return "http://www.worldcat.org/search?&q=#{query}"
  end
  def summon_search(query)
    return "http://brown.preview.summon.serialssolutions.com/#!/search?ho=t&fvf=ContentType,Journal%20Article,f%7CIsScholarly,true,f&l=en&q=#{query}"
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

end
