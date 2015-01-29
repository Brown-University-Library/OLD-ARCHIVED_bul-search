module BdrHelper
  require 'json'
  require 'openssl'
  require 'open-uri'

  ##
  # Attributes for a link that gives a URL we can use to track clicks for the current search session
  # @param [SolrDocument] document
  # @param [Integer] counter
  # @example
  #   session_tracking_params(SolrDocument.new(id: 123), 7)
  #   => { data: { :'tracker-href' => '/catalog/123/track?counter=7&search_id=999' } }
  def bdr_session_tracking_params document, counter
    if document.nil?
      return {}
    end

    { :data => {:'context-href' => bdr_track_path(document['pid'], per_page: params.fetch(:per_page, search_session['per_page']), counter: counter, search_id: current_search_session.try(:id))}}
  end

  ##
  # Render "docuemnt actions" area for search results view
  # (normally renders next to title in the list view)
  #
  # @param [SolrDocument] document
  # @param [Hash] options
  # @option options [String] :wrapping_class
  # @return [String]
  def bdr_render_index_doc_actions(document, options={})
    wrapping_class = options.delete(:wrapping_class) || "index-document-functions"

    content = []
    content << render(:partial => 'bdr/bookmark_control', :locals => {:document=> document}.merge(options)) if render_bookmarks_control?

    content_tag("div", safe_join(content, "\n"), :class=> wrapping_class)
  end

  def bdr_render_constraints(localized_params = params)
    bdr_render_constraints_query(localized_params) + render_constraints_filters(localized_params)
  end

  #Over-ride of Blacklight method, provide advanced constraints if needed,
  # otherwise call super. Existence of an @advanced_query instance variable
  # is our trigger that we're in advanced mode.
  def bdr_render_constraints_query(my_params = params)
    if (@advanced_query.nil? || @advanced_query.keyword_queries.empty? )
      #return super(my_params)
      return render_constraints_query(my_params)
    else
      content = []
      @advanced_query.keyword_queries.each_pair do |field, query|
        label = search_field_def_for_key(field)[:label]
        if my_params[:controller] == 'bdr'
          url = bdr_index_path(remove_advanced_keyword_query(field, my_params))
        else
          url = catalog_index_path(remove_advanced_keyword_query(field,my_params))
        end
        puts "render_constraints_query url: #{url.inspect}"
        content << render_constraint_element(
          label, query,
          :remove => url
        )
      end
      if (@advanced_query.keyword_op == "OR" &&
          @advanced_query.keyword_queries.length > 1)
        content.unshift content_tag(:span, "Any of:", class:'operator')
        content_tag :span, class: "inclusive_or appliedFilter well" do
          safe_join(content.flatten, "\n")
        end
      else
        safe_join(content.flatten, "\n")
      end
    end
  end

  ##Create the item display on index page / results view
  #This matches the catalog.  Rendering code be moved to partial.
  def bdr_render_index_item_subheading document
    raw_date = convert_to_array(document['copyrightDate'])[0]
    if raw_date == nil
      year = nil
    else
      date = raw_date.split('-')
      year = date[0]
    end
    text = []
    text << convert_to_array(document['contributor_display'])[0]
    text << year
    compacted = text.compact
    if compacted == []
      return nil
    else
      return content_tag("div", safe_join(compacted, ". "), :class => "title-subheading")
    end
  end

  ##Display the format and an icon for items in the BDR
  #Need a list of icons to use for BDR formats.  Also should
  #considering normalizing the BDR formats to match catalog
  #as much as possible.
  def render_index_format_subheading document
    format = convert_to_array(document['genre'])
    if ( format.nil?) || ( format.empty?)
    else
      return content_tag("div", format.join("; "), :class => "title-subheading")
    end
  end

end
