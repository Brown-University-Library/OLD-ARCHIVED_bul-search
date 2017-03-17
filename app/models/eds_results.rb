class EdsResults
  attr_reader :items, :facets, :total_hits

  def initialize(items, facets, total_hits)
    @items = items
    @facets = facets
    @total_hits = total_hits
  end

  def self.from_response(response)
    items = items_from_response(response)
    facets = facets_from_response(response)
    total_hits = response["SearchResult"]["Statistics"]["TotalHits"]
    results = EdsResults.new(items, facets, total_hits)
  end

  private
    def self.items_from_response(response)
      items = []
      records = response["SearchResult"]["Data"]["Records"]
      records.each do |r|
        id = r["ResultId"]
        link = r["PLink"]
        title = item_by_name(r["Items"], "Title")
        year = self.get_year(r)
        author = self.get_author(r)
        type = r["Header"]["ResourceType"]
        item = {
          id: id,
          title: title,
          author: author,
          year: year,
          type: type,
          link: link
        }
        items << item
      end
      items
    end

    def self.facets_from_response(response)
      facets = []
      (response["SearchResult"]["AvailableFacets"] || []).each do |f|
        id = f["Id"]
        data = []
        f["AvailableFacetValues"].each do |v|
          value = v["Value"]
          count = v["Count"]
          data << {value: value, count: count}
        end
        facets << {id: id, data: data}
      end
      facets
    end

    def self.item_by_name(items, name)
      item = items.select {|e| e["Name"] == name}.first
      return nil if item == nil
      item["Data"]
    end

    def self.get_author(item)
      item["RecordInfo"]["BibRecord"]["BibRelationships"]["HasContributorRelationships"][0]["PersonEntity"]["Name"]["NameFull"]
    rescue
      return nil
    end

    def self.get_year(item)
      item["RecordInfo"]["BibRecord"]["BibRelationships"]["IsPartOfRelationships"][0]["BibEntity"]["Dates"][0]["Y"]
    rescue
      return nil
    end
end
