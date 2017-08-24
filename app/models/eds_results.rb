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
      response.records.each do |r|
        item = {
          id: r.eds_result_id,
          title: r.eds_title,
          author: clean_author(r.eds_authors.first),
          year: r.eds_publication_year,
          type: r.eds_publication_type,
          link: preferred_link(r),
          venue: r.eds_source_title,
          volume: r.eds_volume,
          issue: r.eds_issue,
          start: r.eds_page_start,
          database: r.eds_database_name
        }
        items << item
      end
      items
    end

    def self.preferred_link(r)
      link = easyarticle_link(r.all_links)
      if link == nil
        link = easyaccess_link(r.all_links)
        if link == nil
          # Prepend revproxy to the EBSCO URL to make sure users
          # go through Shibboleth. Otherwise users working from
          # outside our IP range are confronted with an EBSCO
          # login page. RevProxy makes sure users are presented
          # with Brown's Shibboleth authentication instead.
          link = "https://login.revproxy.brown.edu/login?url=#{r.eds_plink}"
        end
      end
      link
    end

    def self.easyarticle_link(links)
      easy_link(links, "//library.brown.edu/easyarticle/")
    end

    def self.easyaccess_link(links)
      easy_link(links, "//library.brown.edu/easyaccess/find")
    end

    def self.easy_link(links, prefix)
      links.each do |link|
        if (link[:url] || "").include?(prefix)
          return link[:url]
        end
      end
      nil
    end

    def self.results_to_file(response)
      delimiter = ""
      File.open("eds_results.json", 'w') do |file|
        file.write("[\r\n")
        response.records.each do |r|
          file.write(delimiter + r.to_json)
          delimiter = ", \r\n"
        end
        file.write("]\r\n")
      end
      nil
    end

    # Remove the ", Author" postfix on EDS values.
    # We might need to account for other values and/or find out an EDS
    # value that does not include these postfixes.
    def self.clean_author(author)
      return nil if author == nil
      val_to_remove = ", Author"
      value = author.strip
      if value == val_to_remove
        value = nil
      elsif value.end_with?(val_to_remove)
        value = value[0..(value.length()-9)]
      end
      value
    end
end
