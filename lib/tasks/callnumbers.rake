require "./lib/http_json"

namespace :josiah do

  # Caches all the Solr IDs into our SQL database.
  task cache_all_bib_ids: :environment do
    Callnumber.cache_all_bib_ids(blacklight_config)
  end

  # Normalizes all the call numbers in our SQL database
  # that have not been normalized.
  task callnumbers_normalize: :environment do
    Callnumber.normalize_all_pending
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
