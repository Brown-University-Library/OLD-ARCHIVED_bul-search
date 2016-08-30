class SolrQuery

  def initialize(blacklight_config)
    @blacklight_config = blacklight_config
    @solr_url = ENV['SOLR_URL'] || "http://127.0.0.1:8081/solr"
  end

  def query(fq_query, sort = nil, per_page = 10, page = 1)
    solr = RSolr.connect :url => @solr_url
    # TODO: get the facet.* and f.* fields from
    # our configuration rather than hard-coding
    # them here.
    solr_params = {
        :wt=>:json,
        "qt" => 'search',
        "fq"=>"#{fq_query}",
        "start" => per_page * (page -1),
        "rows"=>per_page,
        "page"=>page,
        "facet.field" => "access_facet",
        "facet.field" => "format",
        "facet.field" => "author_facet",
        "facet.field" => "pub_date",
        "facet.field" => "topic_facet",
        "facet.field" => "region_facet",
        "facet.field" => "language_facet",
        "facet.field" => "building_facet",
        "facet" => true,
        "f.format.facet.limit" => 11,
        "f.author_facet.facet.limit" => 21,
        "f.topic_facet.facet.limit" => 21,
        "f.region_facet.facet.limit" => 21,
        "f.language_facet.facet.limit" => 21,
        "stats" => true,
        "stats.field" => "pub_date"
    }
    if sort != nil
      solr_params["sort"] = sort
    end
    solr_response = solr.get 'select', :params => solr_params
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
