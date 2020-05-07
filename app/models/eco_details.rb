require "./app/models/string_utils.rb"

class EcoDetails < ActiveRecord::Base
    def josiah_bib_id
        "b#{bib_record_num}"
    end

    def location_name
        Location.get_name(location_code)
    end

    def subjects_list
        @subject_tokens ||= (self.subjects || "").split("|")
    end

    def subjects_display
        return "" if subjects_list.count == 0
        subjects_list.first || ""
    end

    def subjects_tooltip
        (self.subjects || "")
    end

    def subjects_tooltip?
        return subjects_list.count > 1
    end

    def date_display(value)
        return "" if value == nil
        value.to_date
    end

    def self.by_range(range, max)
        range = EcoRange.find(range.id)
        count = EcoDetails.where(eco_summary_id: range.eco_summary_id, eco_range_id: range.id).count
        if max == -1
            return count, EcoDetails.where(eco_summary_id: range.eco_summary_id, eco_range_id: range.id)
        end
        return count, EcoDetails.where(eco_summary_id: range.eco_summary_id, eco_range_id: range.id).take(max)
    end

    def self.by_location(code, summary_id, max)
        count = EcoDetails.where(eco_summary_id: summary_id, location_code: code).count
        if max == -1
            return count, EcoDetails.where(eco_summary_id: summary_id, location_code: code)
        end
        return count, EcoDetails.where(eco_summary_id: summary_id, location_code: code).take(max)
    end

    def self.by_usage(checkout_total, summary_id, max)
        count = EcoDetails.where(eco_summary_id: summary_id, checkout_total: checkout_total).count
        if max == -1
            return count, EcoDetails.where(eco_summary_id: summary_id, checkout_total: checkout_total)
        end
        return count, EcoDetails.where(eco_summary_id: summary_id, checkout_total: checkout_total).take(max)
    end

    def self.by_summary(summary_id, max)
        count = EcoDetails.where(eco_summary_id: summary_id).count
        if max == -1
            return count, EcoDetails.where(eco_summary_id: summary_id)
        end
        return count, EcoDetails.where(eco_summary_id: summary_id).take(max)
    end

    # Creates a new detail record for a given Solr document
    def self.new_from_solr_doc(eco_summary_id, eco_range_id, doc, range_from, range_to)
        id = doc["id"]
        marc_record = MarcRecord.new(doc["marc_display"])
        subjects = marc_record.subjects()

        # If we don't have items, create a single detail record for the BIB.
        items = marc_record.items()
        if items.count == 0
            record = EcoDetails.new()
            record.eco_summary_id = eco_summary_id
            record.eco_range_id = eco_range_id
            record.bib_record_num = id[1..-1].to_i # the numeric part of the bib
            record.title = StringUtils.truncate(doc["title_display"], 100)
            if (doc["language_facet"] || []).count > 0
                record.language_code = doc["language_facet"].first[0..2]
            end
            record.publish_year = doc["pub_date_sort"]
            record.author = StringUtils.truncate(doc["author_display"], 100)
            record.bib_create_date = marc_record.created_date()
            record.bib_catalog_date = marc_record.cataloged_date()

            callnumbers = (doc["callnumber_ss"] || []).uniq
            best = Callnumber.best_for_range(callnumbers, range_from, range_to)
            if callnumbers.count > 1
                puts "BIB #{id}, #{best[:raw]} <= #{callnumbers.join(' ^^ ')}"
            end
            record.callnumber_raw = best[:raw]
            record.callnumber_norm = best[:norm]

            record.location_code = safe_location_code(marc_record.subfield_values("998", "a").first || "NONE", id)
            if subjects.count > 0
                record.subjects = subjects.join("|")
            end

            record.is_online = doc["online_b"] || false
            record.format = doc["format"] || "UNKNOWN"
            record.save!
            return 1
        end

        # Create one detail record for each item in the BIB.
        items.each do |item|
            record = EcoDetails.new()
            record.eco_summary_id = eco_summary_id
            record.eco_range_id = eco_range_id

            # bib info
            record.bib_record_num = id[1..-1].to_i # the numeric part of the bib
            record.title = StringUtils.truncate(doc["title_display"], 100)
            if (doc["language_facet"] || []).count > 0
                record.language_code = doc["language_facet"].first[0..2]
            end
            record.publish_year = doc["pub_date_sort"]
            record.author = StringUtils.truncate(doc["author_display"], 100)
            record.bib_create_date = marc_record.created_date()
            record.bib_catalog_date = marc_record.cataloged_date()

            # item info
            record.item_record_num = item.id
            record.callnumber_raw = item.call_number
            record.callnumber_norm = CallnumberNormalizer.normalize_one(item.call_number)
            record.location_code = safe_location_code(item.location_code || "NONE", id)
            record.checkout_total = item.checkout_total
            record.checkout_2015_plus = item.checkout_2015_plus
            record.item_create_date = item.created_date
            if subjects.count > 0
                record.subjects = subjects.join("|")
            end

            record.is_online = doc["online_b"] || false
            record.format = doc["format"] || "UNKNOWN"
            record.save!
        end

        return items.count
    end

    def self.safe_location_code(code, bib)
        if (code || "").length > 5
            Rails.logger.error("BIB: #{bib} has an invalid location code: #{code}")
            return code[0..4]
        end
        return code
    end

    # Creates a tab delimited string for a set of EcoDetails rows
    def self.to_tsv(rows)
        Rails.logger.info("Begin generating TSV for #{rows.count} rows")
        lines = []
        rows.each_with_index do |row, i|
            line = []
            line << "#{i+1}\t#{row.josiah_bib_id}\t#{row.item_record_num}\t#{row.title}"
            line << "#{row.publish_year}\t#{row.publisher}\t#{row.location_code}"
            line << "#{row.format}\t#{row.is_online}"
            line << "#{row.checkout_total}\t#{row.checkout_2015_plus}"
            line << "#{row.date_display(row.bib_create_date)}"
            line << "#{row.date_display(row.bib_catalog_date)}"
            line << "#{row.date_display(row.item_create_date)}"
            line << "#{row.callnumber_raw}\t#{row.callnumber_norm}"
            line << "#{row.subjects}"
            lines << line.join("\t")
            if (i % 5000) == 0
                Rails.logger.info("== processed #{i} rows...")
            end
        end
        Rails.logger.info("== processed #{rows.count} rows...")

        str = "#\tbib\titem\ttitle" +
            "\tpub_year\tpublisher\tloc_code" +
            "\tformat\tonline"
            "\tcheckouts\tcheckouts2015" +
            "\tbib_create" +
            "\tbib_catalog" +
            "\titem_create" +
            "\tcall_no\tcall_no_norm" +
            "\tsubjects\r\n"
        str += lines.join("\r\n")

        Rails.logger.info("Generating TSV string for #{rows.count} rows")
        str
    end
end