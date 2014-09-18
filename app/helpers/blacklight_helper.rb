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

  #Borrowed from SearchWorks
  def get_book_ids document
    isbn = add_prefix_to_elements( convert_to_array(document['isbn_t']), 'ISBN' )
    oclc = add_prefix_to_elements( convert_to_array(document['oclc_t']), 'OCLC' )
    #BUL doesn't have LCCNs in Solr index yet.
    lccn = add_prefix_to_elements( convert_to_array(document['lccn_t']), 'LCCN' )

    return { 'isbn' => isbn, 'oclc' => oclc, 'lccn' => lccn }
  end


  def add_prefix_to_elements arr, prefix
    new_array = []

    arr.each do |i|
      new_array.push("#{prefix}#{i}")
    end

    new_array
  end


  def convert_to_array value = []
    arr = []

    arr = value if value.kind_of?(Array)
    arr.push(value) if value.kind_of?(String)

    arr
  end

end