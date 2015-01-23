module EasyHelper
  def data_link(query)
    url_for :controller=>'easy', :action=> 'search', :q => query
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

  # def render_info_text(format)
  #   text = FORMATS[format]
  #   unless text.nil?
  #     info = text['info']
  #     unless info.nil?
  #       render partial: "shared/info_box", locals: {:text => info}
  #     end
  #   end
  # end
end
