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

  task callnumbers_export: :environment do
    created_at = "2016-08-17 15:58:20.357007"
    File.open("callnumbers.txt", "r").each_line do |line|
      tokens = line.strip.split("|")
      id = tokens[0]
      next if id == ""
      original = tokens[1]
      if tokens[2].empty?
        normalized = "NULL"
      else
        normalized = '"' + tokens[2] + '"'
      end
      bib = tokens[3]
      insert_sql = <<-END_SQL.gsub(/\n/, '')
        INSERT INTO callnumbers(id, original, normalized, bib, created_at, updated_at)
        VALUES (#{id}, "#{original}", #{normalized}, "#{bib}", "#{created_at}", "#{created_at}");
      END_SQL
      puts insert_sql
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
