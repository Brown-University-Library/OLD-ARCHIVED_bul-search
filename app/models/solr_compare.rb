class SolrCompare

    class SearchParams
        attr_accessor :id, :search_field, :q, :facets
        def initialize()
            id = nil
            type = "all_fields"
            q = nil
            facets = []
        end
    end

    class Result
        attr_accessor :num_found4, :num_found7
        attr_accessor :top10_matches, :top5_matches, :top1_match
        attr_accessor :params
        def to_s()
            id = @params["id"]
            q = @params["q"]
            counts = "#{@num_found4}/#{@num_found7}".ljust(14)
            "#{counts}\t#{@top10_matches}\t#{@top5_matches}\t#{@top1_match}\t(#{q})\t[#{id}]"
        end
    end

    def initialize()
        raise "No SOLR4_URL defined in ENV" if ENV["SOLR4_URL"] == nil
        raise "No SOLR7_URL defined in ENV" if ENV["SOLR7_URL"] == nil
    end

    def compare(count)
        results = []
        searches = get_saved_searches(count)
        results4 = search_solr(searches, ENV["SOLR4_URL"], true)
        results7 = search_solr(searches, ENV["SOLR7_URL"], false)
        results4.each_with_index do |r4, i|
            # puts "Comparing #{r4['search']} ..."
            r7 = results7[i]
            result = compare_results(r4, r7)
            results << result
        end
        results
    end

    def compare_by_id(id)
        results = []
        searches = get_saved_search(id)
        results4 = search_solr(searches, ENV["SOLR4_URL"], false)
        results7 = search_solr(searches, ENV["SOLR7_URL"], false)
        results4.each_with_index do |r4, i|
            r7 = results7[i]
            result = compare_results(r4, r7)
            results << result
        end
        results
    end

    def compare_results(res4, res7)
        result = Result.new()
        result.params = res4["search"]
        result.num_found4 = res4["response"]["response"]["numFound"]
        result.num_found7 = res7["response"]["response"]["numFound"]

        solr4_top10 = res4["docs"].map { |d| d["id"] }
        solr7_top10 = res7["docs"].map { |d| d["id"] }
        result.top10_matches = compare_ids(solr4_top10, solr7_top10)

        solr4_top5 = solr4_top10[0..4]
        solr7_top5 = solr7_top10[0..4]
        result.top5_matches = compare_ids(solr4_top5, solr7_top5)

        result.top1_match = (solr4_top5[0] == solr7_top5[0])
        result
    end

    def compare_ids(solr4, solr7)
        match_count = 0
        solr4.each do |id|
            if solr7.find {|x| x == id }
                match_count += 1
            end
        end
        match_count
    end

    def search_solr(searches, solr_url, use_cache)
        results = []
        searcher = SolrQuery.new(Blacklight.default_configuration, solr_url)
        searches.each do |s|
            case
                when s.search_field == "all_fields"
                    file = cache_file(s.id)
                    if use_cache && File.exist?(file)
                        # Read cache result
                        result = JSON.parse(File.read(file))
                    else
                        params = {} # TODO account for facets
                        response, docs = searcher.search(s.q, params)
                        num_found = response["response"]["numFound"]
                        result = { search: s, response: response, docs: docs }
                        result_json = result.to_json
                        # Force the result to be a value converted from JSON
                        # back to Ruby to make sure the structure of object is
                        # identical to the one that we will get when we read
                        # from the cache, otherwise the keys are sometimes strings
                        # and others symbols.
                        result = JSON.parse(result_json)
                        if use_cache
                            # Cache this result
                            File.write(file, result_json)
                        end
                    end
                    results << result
                else
                    Rails.logger.info("solr_compare: Skipped search type #{s.search_field}")
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
            begin
                hash = YAML.load(query_params)
                if hash["controller"] == "catalog" &&
                    hash["search_field"] == "all_fields" &&
                    (hash["q"] || "").length > 0
                    params = SearchParams.new()
                    params.id = id
                    params.search_field = hash["search_field"]
                    params.q = hash["q"]
                    # TODO: facets
                    searches << params
                end
            rescue => ex
                Rails.logger.info("solr_compare: Error parsing search #{id}")
            end
        end
        searches
    end

    def get_saved_search(id)
        searches = []
        sql = "select id, query_params from searches where id = #{id}"
        rows = ActiveRecord::Base.connection.exec_query(sql).rows

        rows.each do |row|
            id = row[0].to_i
            query_params = row[1]
            begin
                hash = YAML.load(query_params)
                if hash["controller"] == "catalog" &&
                    hash["search_field"] == "all_fields" &&
                    (hash["q"] || "").length > 0
                    params = SearchParams.new()
                    params.id = id
                    params.search_field = hash["search_field"]
                    params.q = hash["q"]
                    # TODO: facets
                    searches << params
                end
            rescue => ex
                Rails.logger.info("solr_compare: Error parsing search #{id}")
            end
        end
        searches
    end

    def cache_file(id)
        "./searches/#{id}.json"
    end
end