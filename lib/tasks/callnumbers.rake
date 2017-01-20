require "./lib/http_json"

namespace :josiah do
  desc "Saves to the callnumbers table all the BIB + callnumbers"
  task "cache_bib_ids_to_table", [:page]  => :environment do |_cmd, args|
    page = (args[:page] || "1").to_i
    CallnumberCache.cache_bib_ids_to_table(blacklight_config, page)
  end

  desc "Saves to a file SQL INSERT statements to cache BIB + callnumbers"
  task "cache_bib_ids_to_file", [:page] => :environment do |_cmd, args|
    page = (args[:page] || "1").to_i
    CallnumberCache.cache_bib_ids_to_file(blacklight_config, page)
  end

  desc "Normalizes (via API) the callnumbers for a single BIB record"
  task "callnumbers_normalize_one", [:bib] => :environment do |_cmd, args|
    if args[:bib]
      bib = args[:bib]
      puts "Normalizing callnumbers for BIB record #{bib}"
      CallnumberCache.normalize_one(blacklight_config, bib)
    else
      puts "Syntax: callnumbers_normalize_one[bib_id]"
    end
  end

  # Caches data to the callnumbers SQL table. We don't have a version that
  # caches to a text file since we shouldn't have too many.
  desc "Caches callnumbers for BIB records updated since a specific date"
  task "cache_recent_bib_ids", [:date]  => :environment do |_cmd, args|
    date = (args[:date] || "2017-07-01")
    solr_docs = CallnumberCache.cache_bib_ids_since(date)
  end

  private
    def blacklight_config
      Blacklight::Configuration.new do |config|
        config.default_solr_params = {
          :qt => 'search',
          :rows => 10,
          :spellcheck => false
        }
      end
    end
end
