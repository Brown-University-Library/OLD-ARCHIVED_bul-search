module BlacklightHelper
  include Blacklight::BlacklightHelperBehavior

  def application_name
    "Brown University Library Search"
  end

  #Link back to easySearch with the last search if available.
  #
  #Returns a url string to the easy controller.
  def easy_search_link
    #Get the search from the history if it's there or from q param.
    query = @current_search_session.query_params[:q] if @current_search_session.respond_to? :query_params || params[:q]
    if query.nil?
      return url_for :controller=>'easy', :action=> 'home'
    else
      return url_for :controller=>'easy', :action=> 'home', :q => query
    end
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

  ##Overridden here to allow for special BDR item viewing.
  # given a doc and action_name, this method attempts to render a partial template
  # based on the value of doc[:format]
  # if this value is blank (nil/empty) the "default" is used
  # if the partial is not found, the "default" partial is rendered instead
  def render_document_partial(doc, action_name, locals = {})
    format = document_partial_name(doc)
    if (action_name == :show) && (controller_name == 'bdr')
      doc['bdr_data'] = bdr_grab_item_api_data(doc)
    end

    document_partial_path_templates.each do |str|
      # XXX rather than handling this logic through exceptions, maybe there's a Rails internals method
      # for determining if a partial template exists..
      begin
        return render :partial => (str % { :action_name => action_name, :format => format, :index_view_type => document_index_view_type }), :locals => locals.merge({:document=>doc})
      rescue ActionView::MissingTemplate
        nil
      end
    end

    return ''
  end

  def render_show_doc_actions(document=@document, options={})
    wrapping_class = options.delete(:wrapping_class) || "documentFunctions"

    if controller_name == 'bdr'
      partial_location = 'bdr/bookmark_control'
    else
      partial_location = 'catalog/bookmark_control'
    end
    content = []
    content << render(:partial => partial_location, :locals => {:document=> document}.merge(options)) if render_bookmarks_control?

    content_tag("div", safe_join(content, "\n"), :class=> wrapping_class)
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

  # Search History and Saved Searches display
  def link_to_previous_search(params)
    #require 'byebug'; byebug
    if params[:controller] == 'easy'
      query = params[:q]
      url = url_for :controller=>'easy', :action=> 'home', :q => query
      label = render_search_to_s_element(t('blacklight.bento.label'), query)
      link_to(label, url)
    else
      link_to(render_search_to_s(params), search_action_path(params))
    end
  end

end
