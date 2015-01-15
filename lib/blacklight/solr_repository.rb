require "#{Blacklight.root}/lib/blacklight/solr_repository.rb"

#Override SolrRepository to insert different solr url if in config.
Blacklight::SolrRepository.class_eval do
  protected
  def blacklight_solr_config
    solr_url = self.blacklight_config.solr_url
    if solr_url != nil
      return {url: solr_url }
    else
      return @blacklight_solr_config ||= Blacklight.solr_config
    end
  end
end
