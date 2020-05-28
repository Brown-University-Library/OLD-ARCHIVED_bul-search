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

    if params[:search_field] == "call_number_range"
      is_range = false
      cn_from = ""
      cn_to = ""
      tokens = callnumber.split("-")
      if tokens.count == 2
        is_range, cn_from, cn_to = CallnumberNormalizer.normalize_range(tokens[0], tokens[1])
      elsif tokens.count == 1
        is_range, cn_from, cn_to = CallnumberNormalizer.normalize_range(tokens[0], tokens[0])
      end

      if is_range
        response, docs, match = callnumber_range_search(cn_from, cn_to, params)
        return response, docs, match
      end

      # If it is not call number range then we let it run as a normal call number search.
      # The search will most likely fail but we will get a zero results response that
      # we can display to the user.
    end

    response, docs, match = callnumber_search(callnumber, params, "callnumber_ss")
    if docs.count > 0
      # We found a match with the value provided as-is.
      return response, docs, match
    end

    if wildcard_search?(callnumber)
      # Try again using the tokenized format.
      # We are done regardless of the result.
      callnumber = CallnumberUtils::tokenized(callnumber) + "*"
      response, docs, match = callnumber_search(callnumber, params, "callnumber_std_ss")
      return response, docs, match
    end

    tokenized = CallnumberUtils::tokenized(callnumber)
    response, docs, match = callnumber_search(tokenized, params, "callnumber_std_ss")
    if docs.count > 0
      # We found a match with the tokenized value.
      return response, docs, match
    end

    # Try a search without the last token. This is to account for call
    # numbers that include values that we don't index. For an example
    # see record https://search.library.brown.edu/catalog/b2340347, notice
    # that the "33rd" in the call number "1-SIZE GN33 .G85 1994/1995 33rd"
    # is not in the MARC data that we get from Sierra.
    shortened = callnumber_shorten(callnumber)
    shortened = CallnumberUtils::tokenized(shortened)
    if shortened.split("|").count <= 1
      # Shortened version is too short (or empty) we don't retry.
      return response, docs, match
    end

    # Last resort, retry with the shortened tokenized call number.
    response, docs, match = callnumber_search(shortened, params, "callnumber_std_ss")
    return response, docs, match
  end

  def stats_by_format()
    Rails.cache.fetch("format_stats", expires_in: 2.minute) do
      solr_query = SolrQuery.new(@blacklight_config)
      q = "*:*"
      params = {}
      params["rows"] = 0
      params["defType"] = "edismax"
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
    # Surrounds a text in quotes (if needed)
    def quotes(text)
      return nil if text == nil
      if text.length < 2
        return '"' + text + '"'
      elsif text[0] == '"' && text[text.length-1] == '"'
        # already has quotes
        return text
      else
        # add quotes
        return '"' + text + '"'
      end
    end

    def callnumber_search(callnumber, params, callnumber_field)
      params = params || {}
      params["defType"] = "edismax" # Force edismax since Solr is not configured as such.
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

    def callnumber_range_search(cn_from, cn_to, params)
      params = params || {}
      params["defType"] = "edismax" # Force edismax since Solr is not configured as such.
      solr_query = SolrQuery.new(@blacklight_config)

      q = "callnumber_norm_ss:[#{cn_from} TO #{cn_to}]"
      if cn_from == cn_to
        cn_regex = "/" + StringUtils.solr_safe_regex(cn_from) + ".*/"
        q = "callnumber_norm_ss:#{cn_regex}"
      end

      response, docs = solr_query.search(q, params)
      match = cn_from + " - " + cn_to
      return response, docs, match
    end

    # Returns the text in a format suitable for call number search.
    def callnumber_searchable(text)
      text = StringUtils.drop_n_size(text)
      if wildcard_search?(text)
        # Make it a Solr RegEx value
        text = "/" + StringUtils.solr_safe_regex(text.gsub("*", "")) + ".*/"
      else
        text = quotes(text)
      end
      text
    end

    # Shorten a call number by dropping the last token
    def callnumber_shorten(text)
      # delimiter = /[\s\.]+/
      tokens = text.split(/[\s\.]+/)
      return "" if tokens.count < 2
      shorten = tokens[0..-2].join(" ")   # drop the last token
      if wildcard_search?(text)
        shorten += "*"
      end
      callnumber_searchable(shorten)
    end

    # Shorten a call number by dropping the last token
    def callnumber_tokenized_shorten(text)
      delimiter = "|"
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
end
