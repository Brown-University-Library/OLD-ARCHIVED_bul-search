class EdsResults
  attr_reader :items, :facets, :total_hits

  def initialize(items, facets, total_hits)
    @items = items
    @facets = facets
    @total_hits = total_hits
  end

  def self.from_response(response)
    items = items_from_response(response)
    facets = []
    total_hits = response.stat_total_hits
    results = EdsResults.new(items, facets, total_hits)
  end

  private
    def self.items_from_response(response)
      items = []
      byebug
      response.records.each do |r|
        item = {
          id: r.eds_result_id,
          title: r.eds_title,
          author: r.eds_authors,
          year: r.eds_publication_year,
          type: r.eds_publication_type,
          link: r.eds_plink,
          venue: r.eds_source_title,
          volume: r.eds_volume
        }
        # TODO: handle r.Issue
        # (current ebsco-eds gem throws an error with some data)
        items << item
      end
      items
    end
end
