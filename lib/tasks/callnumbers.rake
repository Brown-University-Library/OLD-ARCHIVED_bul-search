require "./lib/http_json"

namespace :josiah do
  desc "Populate normalized call numbers for a given range of bib records"
  task callnumbers_normalize: :environment do
    cache_normalized_callnumbers()
  end

  task nearby_test: :environment do
    # original..: BF698.9.B5 G74 2000
    # normalized: BF 069890B500G740 000 2000
    bib = "b3036567"
    result = Callnumber.nearby_ids(bib)
  end

  def cache_normalized_callnumbers
    solr_url = ENV['SOLR_URL'] || "http://127.0.0.1:8081/solr"
    solr_core = ENV['SOLR_CORE'] || "blacklight-core"
    url = "#{solr_url}/#{solr_core}/select?fq=*%3A*&rows=2000&fl=id%2C+callnumber_t&wt=json&indent=true"
    response = HttpUtil::HttpJson.get(url)
    docs = response["response"]["docs"]
    puts "Processing #{docs.count} documents..."
    docs.each do |doc|
      callnumbers = doc["callnumber_t"] || []
      callnumbers.each do |callnumber|
        Callnumber.normalize_one(doc["id"], callnumber)
      end
    end
    puts "Done."
  end
end
