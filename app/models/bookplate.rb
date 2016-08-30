class Bookplate
  def initialize(blacklight_config)
    @blacklight_config = blacklight_config
  end

  def items_by_code(code, per_page, page)
    solr_query = SolrQuery.new(@blacklight_config)
    fq_query = 'bookplate_code_facet:"' + code + '"'
    order = "pub_date_sort desc"
    solr_query.query(fq_query, order, per_page, page)
  end
end
