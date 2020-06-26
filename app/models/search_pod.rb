class SearchPod
    def initialize(solr_url)
        @solr = SolrLite::Solr.new(solr_url)
        @solr.def_type = "edismax"
    end

    def search_web(req_params, groupped)
        q = req_params[:q] || "*"
        fq = []
        if req_params["f"] != nil
            req_params["f"].keys.each do |key|
                fq << SolrLite::FilterQuery.new(key, req_params["f"][key])
            end
        end

        facets = []
        facets << SolrLite::FacetField.new("access_facet", "Access")
        facets << SolrLite::FacetField.new("format", "Format")
        facets << SolrLite::FacetField.new("author_facet", "Author")
        facets << SolrLite::FacetField.new("pub_date_sort", "Publication Year")
        facets << SolrLite::FacetField.new("topic_facet", "Topic")
        facets << SolrLite::FacetField.new("region_facet", "Region")
        facets << SolrLite::FacetField.new("language_facet", "Language")
        facets << SolrLite::FacetField.new("building_facet", "Location")

        params = SolrLite::SearchParams.new(q, fq, facets)
        params.page = 1
        params.page_size = 10
        params.fl = ["*"]
        params.qf = qf_for_field(req_params["search_field"])
        params.pf = params.qf

        extra_fqs = []
        unused = nil
        mm = nil
        debug = true
        group_field = "oclc_t"
        limit_to = 10
        group_extra = "group.main=true&group.format=simple"
        if groupped
            response = @solr.search_group(params, extra_fqs, unused, mm, debug, group_field, limit_to, group_extra)
        else
            response = @solr.search(params)
        end
        response
    end

    def qf_for_field(field_name)
        qf = ""
        case
        when field_name == "title"
            qf = <<~SOLR
                title_strict_search^10000
                title_unstem_search^5000
                title_other_strict_search^1000
                title_other_unstem_search^500
                title_t^250
                title_series_strict_search^150
                title_series_unstem_search^75
                title_series_t^75
            SOLR
        else
            qf = <<~SOLR
                title_strict_search^10000
                title_unstem_search^5000
                title_other_strict_search^1000
                title_other_unstem_search^500
                title_t^250
                title_series_strict_search^150
                title_series_unstem_search^75
                title_series_t^75
                author_strict_search^4000
                author_unstem_search^2000
                author_t^100
                author_addl_strict_search^150
                author_addl_unstem_search^75
                author_addl_t^50
                subject_strict_search^100
                subject_unstem_search^50
                subject_t^25
                isbn_t
                oclc_t
                issn_t
                text
            SOLR
        end
        qf.gsub("\n"," ")
    end
end