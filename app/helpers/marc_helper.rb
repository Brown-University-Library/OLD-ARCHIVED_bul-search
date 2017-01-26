
module MarcHelper

  def marc_display(document, name)
    document.marc_display_field(name)
  end

  def marc_display_tag(document, number, exclude=[])
    document.marc_tag(number, exclude=exclude)
  end

  def get_search_params(field, query)
    #Remove > for links and replace with blank.
    {:controller => "catalog", :action => 'index', :search_field => field, :q=> query.gsub(/>|--/, '')}
  end

  def get_advanced_search_uniform_title_params(title_q, author_q)
    params = {:controller => "catalog", :action => 'index', :search_field => 'advanced'}
    if ! title_q.empty?
      title_q = title_q.gsub(/>|--/, '') #remove > for links and replace with blank.
      params[:title] = title_q
    end
    if !author_q.nil? && !author_q.empty?
      params[:author] = author_q
    end
    params
  end

  def fielded_search(query, field)
    params = get_search_params(field, query)
    link_url = search_action_path(params)
    link_to(query, link_url)
  end

  def uniform_title_author_search(query, author)
    params = get_advanced_search_uniform_title_params(query, author)
    link_url = search_action_path(params)
    link_to(query, link_url)
  end

  def uniform_title_author_display_search(query, author, display)
    params = get_advanced_search_uniform_title_params(query, author)
    link_url = search_action_path(params)
    link_to(display, link_url)
  end

  def get_link_text(info)
    link_text = ""
    if info['author'] && (! info['author'].empty?)
      link_text += "#{info['author']}."
    end
    if info['title'] && (! info['title'].empty?)
      link_text += " #{info['title']}"
    end
    link_text.strip
  end

  def uniform_related_title_author_search(info)
    params = get_advanced_search_uniform_title_params(info['title'], info['author'])
    link_url = search_action_path(params)
    link_to(get_link_text(info), link_url)
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
    if document.bdr_record?
      to_display = bdr_notes(document)
    elsif document.millenium_record?
      to_display = millenium_notes(document)
    else
      to_display = []
    end
    render partial: "catalog/record/notes", locals: {:note_display => to_display}
  end

  def bdr_notes(document)
    return [] if document["bdr_notes_display"] == nil
    note = {label: "Note", values: document["bdr_notes_display"]}
    [note]
  end

  def millenium_notes(document)
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
    to_display
  end
end
