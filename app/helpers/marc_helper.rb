module MarcHelper

  def marc_display(document, name)
    document.marc_display_field(name)
  end

  def fielded_search(query, field)
    params = {:controller => "catalog", :action => 'index', :search_field => field, :q=> query}
    link_url = search_action_path(params)
    link_to(query, link_url)
  end

  def hot_link(terms, index)
    out = []
    terms.each do |term|
      out << fielded_search(term, index).html_safe
    end
    out
  end

  def toc_link_display(document)
    url = marc_display(document, 'toc_link')
    if url
      content_tag(
        "h6",
        link_to("Online Table of Contents", url),
        :class=> "toc-link"
      )
    end
  end

end