require "./lib/http_json"

namespace :josiah do

  # Caches all the Solr BIB ID and their call numbers into our SQL database.
  # (but it does not normalizes them)
  task "cache_all_bib_ids", [:page]  => :environment do |_cmd, args|
    page = (args[:page] || "1").to_i
    Callnumber.cache_all_bib_ids(blacklight_config, page)
  end

  # Normalizes call numbers for a single BIB record
  # (this uses the call number normalization API)
  task "callnumbers_normalize_one", [:bib] => :environment do |_cmd, args|
    if args[:bib]
      bib = args[:bib]
      puts "Normalizing call numbers for BIB record #{bib}"
      Callnumber.normalize_one(blacklight_config, bib)
    else
      puts "Syntax: callnumbers_normalize_one[bib_id]"
    end
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
