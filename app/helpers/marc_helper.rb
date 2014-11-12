module MarcHelper
  def link_to_author_from_marc(marc, opts={})
      if marc["100"]
        opts[:label] ||= "Author/Creator"
        opts[:search_options] ||= {:controller => "catalog", :action => 'index', :search_field => 'search_author'}
        link, extra, subs = [],[], []
        marc["100"].each do |sub_field|
          #unless Constants::EXCLUDE_FIELDS.include?(sub_field.code)
            subs << sub_field.code
            if subs.include?("e") or subs.include?("4")
              extra << sub_field.value
            else
              link << sub_field.value
            end
          #end
        end
        # vernacular = get_marc_vernacular(marc, marc["100"])
        # unless vernacular.blank?
        #   vernacular = link_to(vernacular, opts[:search_options].merge(:q => "\"#{vernacular}\"")).html_safe
        # end
        vernacular = nil
        {:label  => opts[:label],
         :fields => [{:field      => [link_to(link.join(' '), opts[:search_options].merge(:q => "\"#{link.join(' ')}\"")), extra].flatten.compact.join(" ").html_safe,
                      :vernacular => vernacular
                     }]
        }
      end
  end

  def fielded_search(query, field)
    params = {:controller => "catalog", :action => 'index', :search_field => field, :q=> query}
    link_url = search_action_path(params)
    link_to(query, link_url)
  end

  def render_field_from_marc(fields,opts={})
    render "catalog/field_from_marc", :fields => fields, :options => opts
  end

  def hot_link(terms, index)
    out = []
    terms.each do |term|
      out << fielded_search(term, index).html_safe
    end
    out
  end

end