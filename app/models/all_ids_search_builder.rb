class AllIdsSearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior
  attr_reader :blacklight_config

  def initialize(blacklight_config, page, page_size)
    @blacklight_config = blacklight_config
    @page = page
    @page_size = page_size
    processor_chain = [:fetch_ids]
    scope = nil
    super(processor_chain, scope)
  end

  def fetch_ids(solr_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << "callnumber_t:[* TO *]"
    solr_parameters[:fl] ||= []
    solr_parameters[:fl] << "id"
    solr_parameters[:fl] << "callnumber_t"
    solr_parameters[:sort] = "id asc"
    solr_parameters[:start] = (@page-1) * @page_size
    solr_parameters[:rows] = @page_size
  end
end
