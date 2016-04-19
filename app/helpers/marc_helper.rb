
module MarcHelper

  def marc_display(document, name)
    document.marc_display_field(name)
  end

  def marc_display_tag(document, number, exclude=[])
    document.marc_tag(number, exclude=exclude)
  end

  def fielded_search(query, field)
    #Remove > for links and replace with blank.
    params = {:controller => "catalog", :action => 'index', :search_field => field, :q=> query.gsub(/>|--/, '')}
    link_url = search_action_path(params)
    link_to(query, link_url)
  end

  def quote_string_if_needed(str)
    if ! str.nil? && ! str.empty?
      if ! str.start_with? '"'
        str = "\"#{str}\""
      end
    end
    str
  end

  def quoted_fielded_search(query, field)
    search_query = quote_string_if_needed(query.dup)
    #Remove > for links and replace with blank.
    params = {:controller => "catalog", :action => 'index', :search_field => field, :q=> search_query.gsub(/>|--/, '')}
    link_url = search_action_path(params)
    link_to(query, link_url)
  end

  def uniform_title_author_search(query, author)
    #Remove > for links and replace with blank.
    q = query.gsub(/>|--/, '')
    q = quote_string_if_needed(q)
    params = {:controller => "catalog", :action => 'index', :search_field => 'advanced'}
    params['uniform_title_search_facet'] = q
    params['author'] = author
    link_url = search_action_path(params)
    link_to(query, link_url)
  end

  def uniform_related_title_author_search(info)
    link_text = "#{info['author']} #{info['title']}"
    params = {:controller => "catalog", :action => 'index', :search_field => 'advanced'}
    if ! info['title'].empty?
      params['uniform_title_search_facet'] = quote_string_if_needed(info['title'])
    end
    if ! info['author'].empty?
      params['author'] = info['author']
    end
    link_url = search_action_path(params)
    link_to(link_text, link_url)
  end

  def hot_link(terms, index)
    out = []
    terms.each do |term|
      out << fielded_search(term, index).html_safe
    end
    if out.size == 0
      return nil
    else
      return out
    end
  end

  def icon(format, size=nil, css_class=nil)
    config = Constants::FORMAT[format]
    unless config.nil?
      icon = config[:icon]
      unless icon.nil?
        cls = "fa-#{icon}"
        if size
          cls += " fa-#{size}"
        end
        content_tag('i', '', :class=>"fa #{cls}")
      end
    end
  end

  ##Notes
  def render_record_notes(document)
    config = Constants::NOTES_DISPLAY
    to_display = []
    config.each do |note_config|
      if note_config[:all] == true
        values = document.marc_note(note_config[:tag], options={exclude: []})
      else
        values = document.marc_note(note_config[:tag])
      end
      if !values.nil? && !values.empty?
        to_display << {:label => note_config[:label], :values => values}
      end
    end
    render partial: "catalog/record/notes", locals: {:note_display => to_display}
  end

end
