module BlacklightHelper
  include Blacklight::BlacklightHelperBehavior

  def application_name
    "Brown University Library Search"
  end


  def has_access_urls document
    return !document['url_fulltext_display'].nil?
  end

  #Get links and labels for 856s from the MARC record
  #
  #Returns a hash with links and label text.
  def access_urls document
    url_value = document['url_fulltext_display']
    url_label = document['url_suppl_display'] ||= ["Available online"]
    unless url_value.nil?
        return url_label.zip(url_value).map{|l, u| {:label => l, :url => u} }
    end
  end

end