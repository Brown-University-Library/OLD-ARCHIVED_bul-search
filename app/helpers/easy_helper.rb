module EasyHelper
  def data_link(query)
    url_for :controller=>'easy', :action=> 'search', :q => query
  end
  def app_url
    url_for :controller=>'catalog'
    #return 'bobo'
  end
end
