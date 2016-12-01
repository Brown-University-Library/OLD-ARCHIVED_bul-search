class Shelf
  def initialize(blacklight_config)
    @blacklight_config = blacklight_config
  end

  def nearby_items(id)
    ids = Callnumber.nearby_ids(id)
    items = fetch_ids_from_solr(ids)
    items
  end

  def nearby_items_prev(id, normalized)
    ids = Callnumber.nearby_ids_prev(id, normalized)
    items = fetch_ids_from_solr(ids)
    items
  end

  def nearby_items_next(id, normalized)
    ids = Callnumber.nearby_ids_next(id, normalized)
    items = fetch_ids_from_solr(ids)
    items
  end

  private
    def fetch_ids_from_solr(ids)
      builder = ShelfSearchBuilder.new(@blacklight_config, ids)
      repository = Blacklight::SolrRepository.new(@blacklight_config)
      response = repository.search(builder)
      items = []
      ids.each do |id|
        solr_doc = response.documents.find {|x| x[:id] == id }
        if solr_doc != nil
          items << to_shelf_item(solr_doc)
        end
      end
      items
    end

    def to_shelf_item(solr_doc)
      ShelfItemData.new(solr_doc["id"],
          solr_doc["callnumber_t"],
          solr_doc["author_display"],
          solr_doc["title_display"],
          solr_doc["pub_date"],
          solr_doc["physical_display"],
          solr_doc["isbn_t"]
          )
    end
end
