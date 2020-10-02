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
  task "etd_delete_one", [:id] => :environment do |_cmd, args|
    id = args[:id]
    abort("Must pass a document id to delete") if id == nil
    solr = SolrLite::Solr.new(ENV['SOLR_URL'])
    record = solr.get(id, "fq", "id, record_source_s")
    abort("Document was not found #{id}") if record == nil
    if record["record_source_s"] == "BDR"
      result = solr.delete_by_id(id)
      puts "Deleted #{id}? #{result.ok?}"
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

  desc "Gets the check digit for the BIBs indicated in the proquest.tsv file"
  task "etd_check_digit" => :environment do |_cmd, args|
    solr = SolrLite::Solr.new(ENV['SOLR_URL'])
    proquest_file = "/Users/hectorcorrea/dev/bul-traject/data/proquest.tsv"
    puts "bib\tbib_full\tproquest_id\ttitle"
    File.readlines(proquest_file).each do |line|
      tokens = line.split("\t")
      bib = tokens[0]
      proquest_id = tokens[1]
      title = tokens[2]

      if bib == "NOT FOUN"
        puts "#{bib}\tNOT FOUND\t#{proquest_id}\t#{title}"
        next
      end

      doc = solr.get(bib)
      if doc == nil
        puts "#{bib}\tERROR\t#{proquest_id}\t#{title}"
        next
      end

      record = MarcRecord.new(doc["marc_display"])
      bib_cd = record.subfield_values("907", "a").first[1..-1]

      puts "#{bib}\t#{bib_cd}\t#{proquest_id}\t#{title}"
    end
  end
end
