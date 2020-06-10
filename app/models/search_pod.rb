class SearchPod
    def initialize(solr_url)
        @solr = SolrLite::Solr.new(solr_url)
    end

    def search_web(params)
        q_value = params[:q] || "*"
        q = 'title_strict_search:"' + q_value + '"~10'
        return search(q)
    end

    def search(q)
        params = SolrLite::SearchParams.new()
        params.page = 1
        params.page_size = 10
        params.fl = ["*"]
        params.q = q
        response = @solr.search(params)
        response
    end
end