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
end
