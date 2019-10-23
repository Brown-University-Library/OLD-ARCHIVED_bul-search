require "./app/models/solr_compare.rb"

namespace :josiah do
    task "solr_compare" => :environment do |_cmd, args|
        solr = SolrCompare.new()
        # results = solr.compare_by_id(17184055)
        results = solr.compare(10000)
        results.each do |result|
            puts result
        end
      end
  end
