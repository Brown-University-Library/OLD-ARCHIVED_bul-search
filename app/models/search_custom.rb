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
  def callnumber(callnumber)
    callnumber_searchable = StringUtils.callnumber_searchable(callnumber)
    solr_query = SolrQuery.new(@blacklight_config)
    q =  "callnumber_ss:#{callnumber_searchable}"
    response, docs = solr_query.simple_search(q)
    if docs.count > 0
      Rails.logger.info("Call number search success: #{callnumber}")
      return response, docs, callnumber
    end

    # Try a search without the last token. This is to account for call
    # numbers that include values that we don't index, see for example
    # https://search.library.brown.edu/catalog/b2340347
    # Notice that the "33rd" in the call number "1-SIZE GN33 .G85 1994/1995 33rd"
    # is not in the MARC data that we get from Sierra.
    shortened = StringUtils.call_number_shorten(callnumber)
    if shortened == ""
      # nothing else to try
      return response, docs, callnumber
    end

    # try with the shortened callnumber
    q =  "callnumber_ss:#{shortened}"
    response, docs = solr_query.simple_search(q)
    if docs.count == 0
      return response, docs, callnumber
    end

    return response, docs, StringUtils.drop_quotes(shortened)
  end
end
