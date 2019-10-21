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

        searches = get_searches(count)
        solr4_results = run_solr(searches, ENV["SOLR4_URL"])
        solr7_results = run_solr(searches, ENV["SOLR7_URL"])
        # solr7_results = run_solr7(searches)
    end

    def run_solr(searches, solr_url)
        results = []
        searcher = SolrQuery.new(Blacklight.default_configuration, solr_url)
        searches.each do |s|
            case
                when s.search_field == "all_fields"
                    params = {} # TODO account for facets
                    response, docs = searcher.search(s.q, params)
                    num_found = response["response"]["numFound"]
                    puts "#{s.q} => #{num_found}"
                else
                    puts "Skipped type #{s.search_field}"
            end
        end
    end

    def get_searches(count)
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