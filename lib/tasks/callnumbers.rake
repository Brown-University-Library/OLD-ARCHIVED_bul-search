require "./lib/http_json"

namespace :josiah do
  # Use this to initialize the callnumbers table. (option 1)
  desc "Saves to a file SQL INSERT statements to cache BIB + callnumbers"
  task "callnumbers_cache_to_file", [:page] => :environment do |_cmd, args|
    page = (args[:page] || "1").to_i
    CallnumberCache.cache_bib_ids_to_file(blacklight_config, page)
  end

  # Use this to initialize the callnumbers table. (option 2 - slower)
  desc "Saves to the callnumbers table all the BIB + callnumbers"
  task "callnumbers_cache_to_table", [:page]  => :environment do |_cmd, args|
    page = (args[:page] || "1").to_i
    CallnumberCache.cache_bib_ids_to_table(blacklight_config, page)
  end

  # Caches data to the callnumbers SQL table. We don't have a version that
  # caches to a text file since we shouldn't have too many.
  desc "Caches callnumbers for BIB records updated on or after a specific date"
  task "callnumbers_cache_recent", [:date]  => :environment do |_cmd, args|
    date = (args[:date] || "2017-01-01")
    solr_docs = CallnumberCache.cache_bib_ids_since(date)
  end

  desc "Normalizes (via API) the callnumbers for a single BIB record"
  task "callnumbers_normalize_one", [:bib] => :environment do |_cmd, args|
    if args[:bib]
      bib = args[:bib]
      CallnumberCache.normalize_one(blacklight_config, bib)
    else
      puts "Syntax: callnumbers_normalize_one[bib_id]"
    end
  end

  desc "Normalizes (via API) all callnumbers not normalized in the SQL table"
  task "callnumbers_normalize_pending" => :environment do |_cmd, args|
    CallnumberCache.normalize_pending(blacklight_config)
  end

  # We use this via a cron job to keep the data up to date
  desc "Caches and normalizes callnumbers for items updated on or after a specific date"
  task "callnumbers_catchup", [:date]   => :environment do |_cmd, args|
    date = (args[:date] || (Date.today-14).to_s)
    solr_docs = CallnumberCache.cache_bib_ids_since(date)
    CallnumberCache.normalize_pending(blacklight_config)
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
