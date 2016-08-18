class Shelve
  def initialize(blacklight_config)
    @blacklight_config = blacklight_config
  end

  def nearby_items(id)
    ids = Callnumber.nearby_ids(id)
    items = fetch_ids_from_solr(ids)
    items.each { |item| item.highlight = true if item.id == id }
    items
  end

  private
    def fetch_ids_from_solr(ids)
      builder = ShelveSearchBuilder.new(@blacklight_config, ids)
      repository = Blacklight::SolrRepository.new(@blacklight_config)
      response = repository.search(builder)
      items = []
      ids.each do |id|
        solr_doc = response.documents.find {|x| x[:id] == id }
        if solr_doc != nil
          items << to_shelve_item(solr_doc)
        end
      end
      items
    end

    def to_shelve_item(solr_doc)
      ShelveItemData.new(solr_doc["id"],
          solr_doc["callnumber_t"],
          solr_doc["author_display"],
          solr_doc["title_display"])
    end
end
