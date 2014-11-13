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

end