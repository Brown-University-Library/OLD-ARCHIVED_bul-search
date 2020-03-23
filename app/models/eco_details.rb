require "./app/models/string_utils.rb"

class EcoDetails < ActiveRecord::Base
    def josiah_bib_id
        "b#{bib_record_num}"
    end

    # Creates a new detail record for a given bib number
    def self.new_from_bib(eco_summary_id, eco_range_id, bib)
        solr = SolrLite::Solr.new(ENV['SOLR_URL'])
        doc = solr.get(bib)
        if doc == nil
            return 0
        end

        marc_record = MarcRecord.new(doc["marc_display"])
        items = marc_record.items()
        if items.count == 0
            # BIB level information only
            record = EcoDetails.new()
            record.eco_summary_id = eco_summary_id
            record.eco_range_id = eco_range_id
            record.bib_record_num = bib[1..-1].to_i # the numeric part of the bib
            record.title = StringUtils(doc["title_display"], 100)
            if (doc["language_facet"] || []).count > 0
                record.language_code = doc["language_facet"].first[0..2]
            end
            record.publish_year = doc["pub_date_sort"]
            record.author = StringUtils(doc["author_display"], 100)

            # TODO: how should we handle instances with more than one
            # non-unique call number (e.g. BIB b1012355)
            callnumbers = (doc["callnumber_ss"] || []).uniq
            if callnumbers.count > 1
                puts "BIB #{bib}, with no items, has more than one callnumber #{callnumbers.join(' ^^ ')}"
            end
            record.callnumber_raw = callnumbers.first
            record.callnumber_norm = CallnumberNormalizer.normalize_one(callnumbers.first)

            record.location_code = "NONE"
            record.save!
            return 1
        end

        items.each do |item|
            record = EcoDetails.new()
            record.eco_summary_id = eco_summary_id
            record.eco_range_id = eco_range_id

            # bib info
            record.bib_record_num = bib[1..-1].to_i # the numeric part of the bib
            record.title = StringUtils(doc["title_display"], 100)
            if (doc["language_facet"] || []).count > 0
                record.language_code = doc["language_facet"].first[0..2]
            end
            record.publish_year = doc["pub_date_sort"]
            record.author = StringUtils(doc["author_display"], 100)

            # item info
            record.item_record_num = item.id
            record.callnumber_raw = item.call_number
            record.callnumber_norm = CallnumberNormalizer.normalize_one(item.call_number)
            record.location_code = item.location_code
            record.checkout_total = item.checkout_total

            record.save!
        end

        return items.count
    end

    # Creates a tab delimited string for a set of EcoDetails rows
    def self.to_tsv(rows)
        Rails.logger.info("Begin generating TSV for #{rows.count} rows")
        lines = []
        rows.each_with_index do |row, i|
            line = []
            line << "#{i+1}\t#{row.josiah_bib_id}\t#{row.item_record_num}\t#{row.title}"
            line << "#{row.publish_year}\t#{row.publisher}\t#{row.location_code}"
            line << "#{row.checkout_total}\t#{row.callnumber_raw}\t#{row.marc_value}"
            line << "#{row.ord_record_num}\t#{row.fund_code}\t#{row.fund_code_master}"
            lines << line.join("\t")
            if (i % 5000) == 0
                Rails.logger.info("== processed #{i} rows...")
            end
        end
        Rails.logger.info("== processed #{rows.count} rows...")

        str = "#\tbib\titem\ttitle\t" +
            "pub_year\tpublisher\tloc_code\t" +
            "checkouts\tcall_no\tsubject\t" +
            "order\tfund\tfund_master\r\n"
        str += lines.join("\r\n")

        Rails.logger.info("Generating TSV string for #{rows.count} rows")
        str
    end
end