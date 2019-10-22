class SolrCompare

    class SearchParams
        attr_accessor :search_field, :q, :facets
        def initialize()
            type = "all_fields"
            q = nil
            facets = []
        end
    end

    def initialize()
    end

    def compare(count)
        raise "No SOLR4_URL defined in ENV" if ENV["SOLR4_URL"] == nil
        raise "No SOLR7_URL defined in ENV" if ENV["SOLR7_URL"] == nil

        searches = get_saved_searches(count)
        results4 = search_solr(searches, ENV["SOLR4_URL"])
        results7 = search_solr(searches, ENV["SOLR7_URL"])
        puts "numFound\ttop10\t"
        results4.each_with_index do |r4, i|
            q = r4[:search].q
            r7 = results7[i]
            puts compare_results(r4, r7) + "\t(#{q})"
        end
    end

    def compare_results(res4, res7)
        numFound4 = res4[:response]["response"]["numFound"]
        numFound7 = res4[:response]["response"]["numFound"]
        numFoundMatch = numFound4 = =numFound7
        result = "#{numFoundMatch}\t"

        solr4_top10 = res4[:docs].map { |d| d["id" }
        solr7_top10 = res7[:docs].map { |d| d["id" }
        top10_matches = compare_ids(solr4_top10, solr7_top10)
        result += "#{top10_matches}\t"

        solr4_top5 = solr4_top10[0..4]
        solr7_top5 = solr7_top10[0..4]
        top5_matches = compare_ids(solr4_top5, solr7_top5)
        result += "#{top5_matches}\t"

        top1_match = solr4_top5[0] == solr7_top5[0]
        result += "#{top1_match}"
    end

    def compare_ids(solr4, solr7)
        match_count = 0
        solr4.each do |id|
            if solr7.find {|d| d["id"] == id }
                match_count += 1
            end
        end
    end

    def search_solr(searches, solr_url)
        results = []
        searcher = SolrQuery.new(Blacklight.default_configuration, solr_url)
        searches.each do |s|
            case
                when s.search_field == "all_fields"
                    params = {} # TODO account for facets
                    response, docs = searcher.search(s.q, params)
                    num_found = response["response"]["numFound"]
                    puts "#{s.q} => #{num_found}"
                    result = {search: s, response: response, docs: docs}
                    results << result
                else
                    puts "Skipped type #{s.search_field}"
            end
        end
        results
    end

    def get_saved_searches(count)
        searches = []
        sql = "select id, query_params from searches order by id desc limit #{count}"
        rows = ActiveRecord::Base.connection.exec_query(sql).rows

        rows.each do |row|
            id = row[0].to_i
            query_params = row[1]
            hash = YAML.load(query_params)
            params = SearchParams.new()
            params.search_field = hash["search_field"]
            params.q = hash["q"]
            # TODO: facets
            searches << params
        end
        searches
    end
end