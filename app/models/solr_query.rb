class SolrQuery

  def initialize(blacklight_config)
    @blacklight_config = blacklight_config
    @solr_url = ENV['SOLR_URL'] || "http://127.0.0.1:8081/solr"
  end

  def query(fq_query, sort = nil, per_page = 10, page = 1)
    solr_params = default_solr_params(per_page, page)
    solr_params["fq"] = "#{fq_query}"
    if sort != nil
      solr_params["sort"] = sort
    end
    submit_query(solr_params)
  end

  def simple_search(q, per_page = 10, page = 1)
    solr_params = default_solr_params(per_page, page)
    solr_params["q"] = "#{q}"
    solr_params["defType"] = "edismax"
    submit_query(solr_params)
  end

  private
    def default_solr_params(per_page, page)
      # TODO: get the facets from our configuration rather
      # than hard-coding them here.
      facets = ["access_facet", "format", "author_facet", "pub_date",
        "topic_facet", "region_facet", "language_facet", "building_facet"]

      # Note that wt must be a symbol
      params = {
        :wt => :json,
        "qt" => "search",
        "start" => per_page * (page -1),
        "rows" => per_page,
        "page" => page,
        "facet.field" => facets,
        "facet" => true,
        "stats" => true,
        "stats.field" => "pub_date"
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
