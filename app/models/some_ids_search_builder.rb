class SomeIdsSearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior
  attr_reader :blacklight_config

  def initialize(blacklight_config, ids)
    @blacklight_config = blacklight_config
    @ids = ids
    processor_chain = [:fetch_ids]
    scope = nil
    super(processor_chain, scope)
  end

  def fetch_ids(solr_parameters)
    solr_parameters[:q] = @ids.map {|id| "(id:#{id})"}.join(" OR ")
    solr_parameters[:fq] = []
    solr_parameters[:fl] ||= []
    solr_parameters[:fl] << "id"
    solr_parameters[:fl] << "callnumber_t"
    solr_parameters[:start] = 0
    solr_parameters[:rows] = @ids.count
  end
end
