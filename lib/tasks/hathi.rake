namespace :josiah do
  # See https://www.hathitrust.org/hathifiles
  desc "Finds in our catalog items from the Hathi Trust data file (match is done by OCLC number)"
  task "hathi_oclc_match", [:hathi_file] => :environment do |_cmd, args|
    hathi_file = (args[:hathi_file] || "")
    if hathi_file == ""
        abort "No Hathi file name received"
    end

    solr_url = ENV["SOLR_URL"]
    if solr_url == nil
        abort "No SOLR_URL defined in the environment"
    end

    solr = SolrLite::Solr.new(solr_url)

    File.foreach(hathi_file).with_index do |line, i|
        tokens = line.split("\t")
        oclc_nums = (tokens[7] || "").split(",")
        oclc_nums.each do |oclc_num|
            oclc = oclc_num.gsub(" ", "").gsub("-", "").gsub(":", "")
            oclc = oclc.match(/[0-9A-Z]*/)
            if oclc == nil || oclc == ""
                STDERR.puts "#{i} skipped #{oclc_num}"
                next
            end

            oclc = oclc.to_s
            params = SolrLite::SearchParams.new("oclc_t:#{oclc}")
            params.fl = ["id", "title_display, oclc_t, pub_date_sort"]
            response = solr.search(params)
            if response.ok?
                response.solr_docs.each do |doc|
                    bib = doc["id"]
                    year = doc["pub_date_sort"]
                    puts "#{oclc}\t#{bib}\t#{year}"
                end
            else
                STDERR.puts "#{i} not OK (#{oclc})."
            end
        end
        if (i % 1000) == 0
            STDERR.puts "#{i} ===== "
        end
    end

  end

  # See https://www.hathitrust.org/hathifiles
  desc "Finds the given OCLC number in the Hathi Trust full file"
  task "hathi_oclc_match_one", [:hathi_file, :value] => :environment do |_cmd, args|
    hathi_file = (args[:hathi_file] || "")
    if hathi_file == ""
        abort "No Hathi file name received"
    end
    value = (args[:value] || "")
    if value == ""
        abort "No OCLC number received"
    end
    File.foreach(hathi_file).with_index do |line, i|
        tokens = line.split("\t")
        oclc_nums = (tokens[7] || "").split(",")
        oclc_nums.each do |oclc_num|
            oclc = oclc_num.gsub(" ", "").gsub("-", "").gsub(":", "")
            oclc = oclc.match(/[0-9A-Z]*/)
            next if oclc == nil || oclc == ""
            if oclc.to_s == value
                puts "[#{i}]\t#{line}"
            end
        end
    end
  end
end
