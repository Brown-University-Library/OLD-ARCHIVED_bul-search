require "./app/models/solr_compare.rb"

namespace :josiah do
    task "solr_compare" => :environment do |_cmd, args|
        solr = SolrCompare.new()
        solr.compare(10)
      end
  end
