class SearchCustom
  def initialize(blacklight_config)
    @blacklight_config = blacklight_config
  end

  # Issues a search for the indicated call number. Notice that we use a
  # specific Solr fields (callnumber_ss and callnumber_std_ss) for this
  # and we take into account several gotchas.
  #
  # Returns three values:
  #   response: The blacklight response (suitable for @response)
  #   docs: The documents found (suitable for @document_list)
  #   match: The callnumber that was found (could be different from the one requested)
  #
  def callnumber(callnumber, params)
    callnumber = callnumber.strip
    response, docs, match = callnumber_search(callnumber, params, "callnumber_ss")
    if docs.count > 0
      # We found a match with the value provided as-is.
      return response, docs, match
    end

    if wildcard_search?(callnumber)
      # Try again using the normalized format.
      # We are done regardless of the result.
      callnumber = CallnumberUtils::normalized(callnumber) + "*"
      response, docs, match = callnumber_search(callnumber, params, "callnumber_std_ss")
      return response, docs, match
    end

    normalized = CallnumberUtils::normalized(callnumber)
    response, docs, match = callnumber_search(normalized, params, "callnumber_std_ss")
    if docs.count > 0
      # We found a match with the normalized value.
      return response, docs, match
    end

    # Try a search without the last token. This is to account for call
    # numbers that include values that we don't index. For an example
    # see record https://search.library.brown.edu/catalog/b2340347, notice
    # that the "33rd" in the call number "1-SIZE GN33 .G85 1994/1995 33rd"
    # is not in the MARC data that we get from Sierra.
    #
    #   TODO: We currently issue two shortened searches. First we shorten the
    #   value as entered by the user. If that fails, then we shorten the
    #   normalized value. I believe we can just issue one search using the
    #   shorten normalized value, but I have not tested that. For now, we'll
    #   keep them both.
    #
    shortened = callnumber_shorten(callnumber, " ")
    if shortened == ""
      # No short version to retry, we are done.
      return response, docs, match
    end

    response, docs, match = callnumber_search(shortened, params, "callnumber_ss")
    if docs.count > 0
      # We found a match with the shortened value.
      return response, docs, match
    end

    shortened = callnumber_shorten(normalized, "|")
    if shortened == ""
      # No short version to retry, we are done
      return response, docs, match
    end

    # Retry with the shortened normalized call number.
    response, docs, match = callnumber_search(shortened, params, "callnumber_std_ss")
    return response, docs, match
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
    def callnumber_search(callnumber, params, callnumber_field)
      params = params || {}
      search_term = callnumber_searchable(callnumber)
      solr_query = SolrQuery.new(@blacklight_config)
      if search_term == ""
        q = "*:*"
      else
        q =  "#{callnumber_field}:#{search_term}"
      end

      response, docs = solr_query.search(q, params)
      return response, docs, callnumber
    end

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
    def callnumber_shorten(text, delimiter = " ")
      tokens = text.split(delimiter)
      return "" if tokens.count < 2
      shorten = tokens[0..-2].join(delimiter)   # drop the last token
      if wildcard_search?(text)
        shorten += "*"
      end
      callnumber_searchable(shorten)
    end

    # Returns the value in a human friendly way (i.e. removes
    # the values added in callnumber_searchable())
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
          when c == "+" || c == "." || c == "*" || c == "/" || c == "|"
            safe_value += "\\" + c
          else
            safe_value += "."
        end
      end
      safe_value
    end
end
