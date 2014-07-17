module EasyHelper
  def data_link(query)
    url_for :controller=>'easy', :action=> 'search', :q => query
  end
end
