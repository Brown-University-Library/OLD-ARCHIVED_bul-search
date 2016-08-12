class ShelveSearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior
  attr_reader :blacklight_config

  def initialize(blacklight_config, search_token, page, per_page)
    @blacklight_config = blacklight_config
    @search_token = search_token
    @page = page
    @per_page = per_page
    processor_chain = [:search_by_callnumber]
    scope = nil
    super(processor_chain, scope)
  end

  def search_by_callnumber(solr_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << "callnumber_t:#{@search_token}*"
    solr_parameters[:fl] ||= []
    solr_parameters[:fl] << "id"
    solr_parameters[:fl] << "callnumber_t"
    solr_parameters[:fl] << "title_display"
    solr_parameters[:fl] << "author_display"
    solr_parameters[:start] = (@page-1) * @per_page
    solr_parameters[:rows] = @per_page
  end
end

class Shelve
  def initialize(blacklight_config)
    @blacklight_config = blacklight_config
  end

  def nearby_items(callnumber, page, per_page)
    search_token = Callnumber.new(callnumber).lc_subclass
    builder = ShelveSearchBuilder.new(@blacklight_config, search_token, page, per_page)
    repository = Blacklight::SolrRepository.new(@blacklight_config)
    response = repository.search(builder)
    response
  end
end
