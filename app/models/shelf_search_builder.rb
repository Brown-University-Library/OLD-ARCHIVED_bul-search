class ShelfSearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior
  attr_reader :blacklight_config

  def initialize(blacklight_config, ids)
    @blacklight_config = blacklight_config
    @ids = ids
    processor_chain = [:search_by_callnumber]
    scope = nil
    super(processor_chain, scope)
  end

  def search_by_callnumber(solr_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << query_for_ids(@ids)
    solr_parameters[:fl] ||= []
    solr_parameters[:fl] << "id"
    solr_parameters[:fl] << "callnumber_t"
    solr_parameters[:fl] << "title_display"
    solr_parameters[:fl] << "author_display"
    solr_parameters[:fl] << "pub_date"
    solr_parameters[:fl] << "physical_display"
    solr_parameters[:start] = 0
    solr_parameters[:rows] = @ids.count
  end

  def query_for_ids(ids)
    query = ""
    ids.each_with_index do |id, index|
      query += "(id:#{id})"
      if index < ids.count-1
        query += " or "
      end
    end
    query
  end
end
