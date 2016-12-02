class Shelf
  def initialize(blacklight_config)
    @blacklight_config = blacklight_config
  end

  def nearby_items(id)
    nearby = Callnumber.nearby_ids(id)
    items = fetch_ids_from_solr(nearby)
    items
  end

  def nearby_items_prev(id, normalized)
    nearby = Callnumber.nearby_ids_prev(id, normalized)
    items = fetch_ids_from_solr(nearby)
    items
  end

  def nearby_items_next(id, normalized)
    nearby = Callnumber.nearby_ids_next(id, normalized)
    items = fetch_ids_from_solr(nearby)
    items
  end

  private
    def fetch_ids_from_solr(nearby)
      builder = ShelfSearchBuilder.new(@blacklight_config, nearby[:ids])
      repository = Blacklight::SolrRepository.new(@blacklight_config)
      response = repository.search(builder)
      items = []
      nearby[:ids].each_with_index do |id, index|
        solr_doc = response.documents.find {|x| x[:id] == id }
        if solr_doc != nil
          normalized = nil
          if index == 0
            normalized = nearby[:bounds][:top]
          end
          if index == nearby[:ids].count-1
            normalized = nearby[:bounds][:bottom]
          end
          shelf_item = to_shelf_item(solr_doc, normalized)
          items << shelf_item
        end
      end
      items
    end

    def to_shelf_item(solr_doc, normalized)
      ShelfItemData.new(solr_doc["id"],
          solr_doc["callnumber_t"],
          solr_doc["author_display"],
          solr_doc["title_display"],
          solr_doc["pub_date"],
          solr_doc["physical_display"],
          solr_doc["isbn_t"],
          normalized)
    end
end
