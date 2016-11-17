require "./lib/http_json"

namespace :josiah do

  desc "Saves to the callnumbers table all the BIB + callnumbers"
  task "cache_bib_ids_to_table" => :environment do |_cmd, args|
    Callnumber.cache_bib_ids_to_table(blacklight_config)
  end

  desc "Saves to a file SQL INSERT statements to cache BIB + callnumbers"
  task "cache_bib_ids_to_file" => :environment do |_cmd, args|
    Callnumber.cache_bib_ids_to_file(blacklight_config)
  end

  desc "Normalizes (via API) the call numbers for a single BIB record"
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
