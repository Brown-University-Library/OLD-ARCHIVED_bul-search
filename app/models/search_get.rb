class SearchGet
    def self.many(solr_url, bibs)
        solr = SolrLite::Solr.new(solr_url)

        q = bibs.map { |bib| "(id:#{bib})" }.join(" OR ")
        params = SolrLite::SearchParams.new(q, [], [])
        params.page = 1
        params.page_size = bibs.count
        params.fl = ["*"]
        solr.search(params)
    end
end