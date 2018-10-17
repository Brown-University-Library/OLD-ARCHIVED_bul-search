class SearchCustom
  def initialize(blacklight_config)
    @blacklight_config = blacklight_config
  end

  # Issues a search for the indicated call number. Notice that we use a
  # specific Solr field (callnumber_ss) for this and we take into account
  # several gotchas.
  #
  # Returns three values:
  #   response: The blacklight response (suitable for @response)
  #   docs: The documents found (suitable for @document_list)
  #   match: The callnumber that was found (could be different from the one requested)
  def callnumber(callnumber, params)
    params = params || {}
    search_term = callnumber_searchable(callnumber)
    solr_query = SolrQuery.new(@blacklight_config)
    if search_term == ""
      q = "*:*"
    else
      q =  "callnumber_ss:#{search_term}"
    end

    response, docs = solr_query.search(q, params)
    if docs.count > 0
      # We are done
      return response, docs, callnumber
    end

    if wildcard_search?(callnumber)
      # Don't retry wildcard searches
      return response, docs, callnumber
    end

    # Try a search without the last token. This is to account for call
    # numbers that include values that we don't index, see for example
    # https://search.library.brown.edu/catalog/b2340347
    # Notice that the "33rd" in the call number "1-SIZE GN33 .G85 1994/1995 33rd"
    # is not in the MARC data that we get from Sierra.
    shortened = callnumber_shorten(callnumber)
    if shortened == ""
      # Nothing else to try
      return response, docs, callnumber
    end

    q =  "callnumber_ss:#{shortened}"
    response, docs = solr_query.search(q, params)
    if docs.count == 0
      return response, docs, callnumber
    end

    return response, docs, callnumber_human(shortened)
  end

  def stats_by_format()
    Rails.cache.fetch("format_stats", expires_in: 2.minute) do
      solr_query = SolrQuery.new(@blacklight_config)
      q = "*:*"
      params = {}
      params["rows"] = 0
      response, docs = solr_query.search(q, params)

      # values is an array in the form ["format1", count1, "format2", count2, ...]
      values = response["facet_counts"]["facet_fields"]["format"]
      pairs_count = (values.count/2)
      stats = []
      (0..pairs_count-1).each do |i|
        x = i * 2
        if values[x] == "3D object"
          # ignore it
        else
          stats << {format: values[x], count: values[x+1]}
        end
      end
      stats.sort_by {|x| x[:format]}
    end
  end

  private
    # Returns the text in a format suitable for call number search.
    def callnumber_searchable(text)
      # Drop the N-SIZE prefix since we don't index it.
      text = text.strip.gsub(/\d-SIZE\s/,"")
      if text == ""
        return ""
      end
      if wildcard_search?(text)
        # Make it a Solr RegEx value
        text = "/" + solr_safe_regex(text.gsub("*", "")) + ".*/"
      else
        # Surround the value in quotes
        text = '"' + text + '"'
      end
      text
    end

    # Shorten a call number by dropping the last token
    def callnumber_shorten(text)
      tokens = text.split(" ")
      return "" if tokens.count < 2
      shorten = tokens[0..-2].join(" ") # drop the last token
      if wildcard_search?(text)
        shorten += "*"
      end
      callnumber_searchable(shorten)
    end

    # Returns the value in a human friendly way (i.e. removes the values added
    # in callnumber_searchable())
    def callnumber_human(text)
      if text.length > 2 && text[0] == '"' && text[-1] == '"'
        # Drop the quotes
        return text[1..-2]
      end
      if text.length > 4 && text[0] == '/' && text.end_with?('.*/')
        # Drop the Solr RegEx markers
        return text[1..-4] + "*"
      end
      text || ""
    end

    def wildcard_search?(text)
      return text.strip.end_with?("*")
    end

    # TODO: move this to a shared class so it's not duplicated with
    # bookplate_regex in catalog_controller.rb
    def solr_safe_regex(value)
      safe_value = ""
      value.each_char do |c|
        case
          when (c >= "a" && c <= "z") || (c >= "A" && c <= "Z") ||
            (c >= "0" && c <= "9") || c == " " || c == "_"
            safe_value += c
          when c == "+" || c == "." || c == "*" || c == "/"
            safe_value += "\\" + c
          else
            safe_value += "."
        end
      end
      safe_value
    end
end
