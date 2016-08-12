class ItemSearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior
  attr_reader :blacklight_config

  def initialize(blacklight_config, code, page, per_page)
    @blacklight_config = blacklight_config
    @code = code
    @page = page
    @per_page = per_page
    processor_chain = [:search_by_location_code]
    scope = nil
    super(processor_chain, scope)
  end

  def search_by_location_code(solr_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << "location_code_t:#{@code}"
    solr_parameters[:start] = (@page-1) * @per_page
    solr_parameters[:rows] = @per_page
  end
end


class Item
  attr_accessor :page, :per_page

  def initialize(blacklight_config)
    @blacklight_config = blacklight_config
  end

  def by_location(code, page, per_page)
    repository = Blacklight::SolrRepository.new(@blacklight_config)
    builder = ItemSearchBuilder.new(@blacklight_config, code, page, per_page)
    response = repository.search(builder)
    response
  end
end
