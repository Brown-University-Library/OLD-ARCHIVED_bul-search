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
    def self.new_from_solr_doc(eco_summary_id, eco_range_id, doc, range_from, range_to, buildings = [])
        id = doc["id"]
        marc_record = MarcRecord.new(doc["marc_display"])
        subjects = marc_record.subjects()

        # If we don't have items, create a single detail record for the BIB.
        items = marc_record.items()
        if items.count == 0

            loc_code = safe_location_code(marc_record.subfield_values("998", "a").first || "NONE", id)
            if !allowed_building(loc_code, buildings)
                return 0
            end

            record = EcoDetails.new()
            record.eco_summary_id = eco_summary_id
            record.eco_range_id = eco_range_id
            record.bib_record_num = id[1..-1].to_i # the numeric part of the bib
            record.title = StringUtils.truncate(doc["title_display"], 100)
            # record.language_code = safe_language_code(doc["language_facet"])
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
            record.location_code = loc_code
            if subjects.count > 0
                record.subjects = subjects.join("|")
            end

            record.is_online = doc["online_b"] || false
            record.format = doc["format"] || "UNKNOWN"
            record.save!
            return 1
        end

        # Create one detail record for each item in the BIB.
        items_added = 0
        items.each do |item|

            loc_code = safe_location_code(item.location_code || "NONE", id)
            if !allowed_building(loc_code, buildings)
                next
            end

            record = EcoDetails.new()
            record.eco_summary_id = eco_summary_id
            record.eco_range_id = eco_range_id

            # bib info
            record.bib_record_num = id[1..-1].to_i # the numeric part of the bib
            record.title = StringUtils.truncate(doc["title_display"], 100)
            # record.language_code = safe_language_code(doc["language_facet"])
            record.publish_year = doc["pub_date_sort"]
            record.author = StringUtils.truncate(doc["author_display"], 100)
            record.bib_create_date = marc_record.created_date()
            record.bib_catalog_date = marc_record.cataloged_date()

            # item info
            record.item_record_num = item.id
            record.callnumber_raw = item.call_number
            record.callnumber_norm = CallnumberNormalizer.normalize_one(item.call_number)
            record.location_code = loc_code
            record.checkout_total = item.checkout_total
            record.checkout_2015_plus = item.checkout_2015_plus
            record.item_create_date = item.created_date
            if subjects.count > 0
                record.subjects = subjects.join("|")
            end

            record.is_online = doc["online_b"] || false
            record.format = doc["format"] || "UNKNOWN"
            record.save!
            items_added += 1
        end

        return items_added
    end

    # Returns an array with the languages in the document
    # and counts for online vs print. Notice that it works
    # at the BIB level (hence the count of 1) and not at
    # the item level.
    def self.langs_from_solr_doc(doc)
        langs = []
        (doc["language_facet"] || []).uniq.each do |lang|
            if doc["online_b"] || false
                langs << {lang => {print: 0, online: 1}}
            else
                langs << {lang => {print: 1, online: 0}}
            end
        end
        langs
    end


    def self.safe_location_code(code, bib)
        if (code || "").length > 5
            Rails.logger.error("BIB: #{bib} has an invalid location code: #{code}")
            return code[0..4]
        end
        return code
    end

    def self.allowed_building(code, buildings)
        name = (Building.name(code) || "").downcase
        return false if name == ""
        buildings.select {|b| b.downcase == name }.count > 0
    end

    def self.to_tsv_file(filename, id)
        Rails.logger.info("Begin saving TSV file #{filename}")
        File.open(filename, "w") do |file|

            # Header row
            tokens = []
            tokens << "#"
            tokens << "bib"
            tokens << "item"
            tokens << "title"
            tokens << "pub_year"
            tokens << "publisher"
            tokens << "loc_code"
            tokens << "format"
            tokens << "online"
            tokens << "checkouts"
            tokens << "checkouts2015"
            tokens << "bib_create"
            tokens << "bib_catalog"
            tokens << "item_create"
            tokens << "call_no"
            tokens << "call_no_norm"
            tokens << "subjects"
            line = tokens.join("\t") + "\r\n"
            file.write(line)

            # Data rows
            i = 0
            EcoDetails.where(eco_summary_id: id).find_each do |row|
                i += 1
                tokens = []
                tokens << "#{i}"
                tokens << "#{row.josiah_bib_id}"
                tokens << "#{row.item_record_num}"
                tokens << "#{row.title}"
                tokens << "#{row.publish_year}"
                tokens << "#{row.publisher}"
                tokens << "#{row.location_code}"
                tokens << "#{row.format}"
                tokens << "#{row.is_online}"
                tokens << "#{row.checkout_total}"
                tokens << "#{row.checkout_2015_plus}"
                tokens << "#{row.date_display(row.bib_create_date)}"
                tokens << "#{row.date_display(row.bib_catalog_date)}"
                tokens << "#{row.date_display(row.item_create_date)}"
                tokens << "#{row.callnumber_raw}"
                tokens << "#{row.callnumber_norm}"
                tokens << "#{row.subjects}"
                line = tokens.join("\t") + "\r\n"
                file.write(line)
                if (i % 500) == 0
                    Rails.logger.info("== processed #{i} rows...")
                end
            end # where.find_each
        end # file
        Rails.logger.info("Done saving TSV file #{filename}")
    end
end