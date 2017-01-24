require "./lib/solr_lite/solr.rb"
require "./app/models/etd_import.rb"

namespace :josiah do
  desc "Imports an ETD from the BDR"
  task "import_etd", [:pid] => :environment do |_cmd, args|
    pid = args[:pid]
    abort("Must pass a BRD pid import") if pid == nil
    puts "Importing ETD #{pid}..."
    importer = EtdImport.new
    ok = importer.one_from_bdr(pid)
    puts "Imported #{pid} OK? #{ok}"
  end

  desc "Imports all ETD from the BDR"
  task "import_etd_all" => :environment do |_cmd, args|
    puts "Importing all ETDs..."
    importer = EtdImport.new
    importer.all_from_bdr()
    puts "Done."
  end

  desc "Fetches an ETD"
  task "get_etd", [:id] => :environment do |_cmd, args|
    id = args[:id]
    abort("Must pass an id to fetch") if id == nil
    puts "Fetching ETD #{id}..."
    solr_url = ENV['SOLR_URL'] || "http://127.0.0.1:8081/solr/blacklight-core"
    solr = SolrLite::Solr.new(solr_url)
    doc = solr.get(id, "fq", "id, title_display, author_display")
    puts doc
  end
end
