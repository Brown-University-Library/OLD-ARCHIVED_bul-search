require "./lib/solr_lite/solr.rb"
require "./app/models/etd_import.rb"

namespace :josiah do
  desc "Imports an ETD from the BDR"
  task "etd_import_one", [:pid] => :environment do |_cmd, args|
    pid = args[:pid]
    abort("Must pass a BRD pid import") if pid == nil
    puts "Importing ETD #{pid}..."
    importer = EtdImport.new
    ok = importer.one_from_bdr(pid)
    puts "Imported #{pid} OK? #{ok}"
  end

  desc "Imports all ETD from the BDR"
  task "etd_import_all" => :environment do |_cmd, args|
    puts "Importing all ETDs..."
    importer = EtdImport.new
    importer.all_from_bdr()
    puts "Done."
  end

  desc "Deletes a BDR ETD from Josiah"
  task "etd_delete", [:id] => :environment do |_cmd, args|
    id = args[:id]
    abort("Must pass an document id to delete") if id == nil
    solr = SolrLite::Solr.new(ENV['SOLR_URL'])
    record = solr.get(id, "fq", "id, record_source_s")
    abort("Document was not found #{id}") if record == nil
    if record["record_source_s"] == "BDR"
      puts "Deleted #{id}? #{solr.delete_by_id(id)}"
    else
      puts "Document was NOT deleted because it's not a BDR record"
    end
  end

  desc "Deletes all BDR ETDs from Josiah"
  task "etd_delete_all" => :environment do |_cmd, args|
    solr = SolrLite::Solr.new(ENV['SOLR_URL'])
    query = "record_source_s:BDR"
    deleted = solr.delete_by_query("record_source_s:BDR")
    puts "Deleted all records that came from the BDR: #{deleted.ok?}"
  end
end
