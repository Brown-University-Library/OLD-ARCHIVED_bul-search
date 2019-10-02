# Issues a request to Solr via RSolr to mimic what Blacklight
# does on a normal search. We use this class to execute special
# searches while making sure the response is compatible with
# what Blacklight normalize returns. The main uses at this time
# are call number searches (from the Catalog controller) and
# Relevancy searches (from the Tests)
class SolrQuery
  def initialize(blacklight_config, solr_url = nil)
    @blacklight_config = blacklight_config
    @solr_url = solr_url || ENV['SOLR_URL']
  end

  def query(fq_query, sort = nil, per_page = 10, page = 1)
    solr_params = default_solr_params(per_page, page)
    solr_params["fq"] = "#{fq_query}"
    if sort != nil
      solr_params["sort"] = sort
    end
    submit_query(solr_params)
  end

  # q is the string to search
  # params is a hash with the value in the Request (as received in
  # a typical Rails controller)
  def search(q, params)
    solr_params = default_solr_params(params)
    solr_params["q"] = q
    facets = params["f"] || {}
    if facets.keys.count > 0
      # facets is a hash in the form {"facet1": "value1", "facet2": "value2"}
      solr_params["fq"] = []
      facets.keys.each do |key|
        facets[key].each do |value|
          solr_params["fq"] << "#{key}:\"#{value}\""
        end
      end
    end
    submit_query(solr_params)
  end

  # This is a strange way to fetch by ID but this is the way the Relevancy tests
  # had it implement it so for now we'll just preserve it.
  def search_by_id(id, params)
    params["fq"] = "id:#{id}"
    search(nil, params)
  end

  def search_by_title(title, params)
    q = "{!qf=$title_qf pf=$title_pf}#{title}"
    search(q, params)
  end

  def search_by_author(title, params)
    q = "{!qf=$author_qf pf=$author_pf}#{title}"
    search(q, params)
  end

  def search_by_title_author(title, author, params)
    q = "_query_:\"{!dismax spellcheck.dictionary=title qf=$title_qf pf=$title_pf}#{title}\" AND _query_:\"{!dismax spellcheck.dictionary=author qf=$author_qf pf=$author_pf}#{author}\""
    params["defType"] = "lucene"
    search(q, params)
  end

  private
    def default_solr_params(custom)
      per_page = (custom["rows"] || "10").to_i
      page = (custom["page"] || "1").to_i

      # TODO: get the facets from our configuration rather
      # than hard-coding them here.
      facets = ["access_facet", "format", "author_facet", "pub_date_sort",
        "topic_facet", "region_facet", "language_facet", "building_facet"]

      # Note that wt must be a symbol
      params = {
        :wt => :json,
        "qt" => (custom["qt"] || "search"),
        "start" => per_page * (page - 1),
        "rows" => per_page,
        "page" => page,
        "facet.field" => facets,
        "facet" => true,
        "stats" => true,
        "stats.field" => "pub_date_sort",
        "fq" => custom["fq"],
        "defType" => custom["defType"]
      }

      facets.each do |field_name|
        limit = field_name == "format" ? 11 : 21
        params["f.#{field_name}.facet.limit"] = limit
      end

      params
    end

    def submit_query(solr_params)
      solr = RSolr.connect :url => @solr_url
      solr_response = solr.get("select", :params => solr_params)
      solr_response.deep_stringify_keys!
      bl_response = @blacklight_config.response_model.new(
        solr_response,
        solr_params,
        document_model: @blacklight_config.document_model,
        blacklight_config: @blacklight_config
      )
      return bl_response, bl_response.documents
    end
end
