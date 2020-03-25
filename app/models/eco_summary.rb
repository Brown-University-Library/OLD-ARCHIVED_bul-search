class EcoSummary < ActiveRecord::Base
    def updated_date
        if self.updated_date_gmt == nil
            return ""
        end
        self.updated_date_gmt.localtime
    end

    def list_full_name
        if sierra_list == nil
            return list_name
        end
        "#{list_name} (Sierra List #{sierra_list})"
    end

    def fund_codes
        @fund_codes ||= begin
            # The "Name" value has both the "code" and the "master"
            # code values as a single string.
            # Here we split them into individual values.
            data = JSON.parse(self.fundcodes_str || "[]")
            data.map do |fund|
                code, master = fund["Name"].split("|")
                {"Name" => code || "", "Master" => master || "", "Count" => fund["Count"]}
            end
        end
        @fund_codes
    end

    def locations
        @locations ||= begin
            JSON.parse(self.locations_str || "[]")
        end
    end

    def subjects
        @subjects ||= begin
            JSON.parse(self.subjects_str || "[]")
        end
    end

    def callnumbers
        @callnumbers ||= begin
            JSON.parse(self.callnumbers_str || "[]")
        end
    end

    def checkouts
        @checkouts ||= begin
            JSON.parse(self.checkouts_str || "[]")
        end
    end

    def ranges()
        EcoRange.where(eco_summary_id: id)
    end

    def total_bibs()
        @bib_count ||= begin
            puts "Calculating bib count..."
            sql = <<-END_SQL.gsub(/\n/, '')
                select count(distinct bib_record_num) as count
                from eco_details
                where eco_summary_id = #{id}
            END_SQL
            rows = ActiveRecord::Base.connection.exec_query(sql).rows
            if rows.count == 0
                0
            else
                rows[0][0]
            end
        end
    end

    def total_items()
        @item_count ||= begin
            puts "Calculating item count..."
            sql = <<-END_SQL.gsub(/\n/, '')
                select count(distinct id) as count
                from eco_details
                where eco_summary_id = #{id}
            END_SQL
            rows = ActiveRecord::Base.connection.exec_query(sql).rows
            if rows.count == 0
                0
            else
                rows[0][0]
            end
        end
    end

    def locations()
        sql = <<-END_SQL.gsub(/\n/, '')
            select location_code as location_code, count(*) as count
            from eco_details
            where eco_summary_id = #{id}
            group by location_code
            order by 2 desc, 1 asc
        END_SQL
        rows = ActiveRecord::Base.connection.exec_query(sql).rows
        data = rows.map do |r|
            percent = (total_items == 0) ? 0 : ((r[1] * 100) / total_items)
            name = Location.get_name(r[0])
            OpenStruct.new(name: name, code: r[0], count: r[1], percent: percent)
        end
        data
    end

    def checkouts()
        sql = <<-END_SQL.gsub(/\n/, '')
            select checkout_total as checkout_total, count(*) as count
            from eco_details
            where eco_summary_id = #{id}
            group by checkout_total
            order by 1 desc, 2 asc
        END_SQL
        rows = ActiveRecord::Base.connection.exec_query(sql).rows
        data = rows.map do |r|
            percent = (total_items == 0) ? 0 : ((r[1] * 100) / total_items)
            OpenStruct.new(code: r[0].to_s, count: r[1], percent: percent)
        end
        # data.sort {|a, b| a.count <=> b.count}.reverse
        data
    end

    # Reloads the details for the current EcoSummary which means
    # getting the list of bib records that match the call number
    # ranges for this EcoSummary.
    def refresh()
        # Delete previous details for this list...
        EcoDetails.delete_all("eco_summary_id = #{id}")

        # ...and fetch those records again based on the current
        # call number ranges.
        # TODO: optimize this code to insert in batches
        ranges().each do |range|
            bibs = Callnumber.get_by_range(range.from, range.to)
            items_count = 0
            bibs.each do |bib|
                items_count += EcoDetails.new_from_bib(id, range.id, bib[:id])
            end
            range.count = items_count
            range.save!
        end

        self.updated_date_gmt = Time.now.utc
        save!
    end

    def refresh_range(range_id)
        # Delete previous details for this range...
        EcoDetails.delete_all(eco_summary_id: id, eco_range_id: range_id)

        # ...fetch items for the call number range and re-save them
        # TODO: optimize this code to insert in batches
        range = ranges().find {|r| r.id == range_id}
        if range != nil
            bibs = Callnumber.get_by_range(range.from, range.to)
            items_count = 0
            bibs.each do |bib|
                items_count += EcoDetails.new_from_bib(id, range.id, bib[:id])
            end
            range.count = items_count
            range.save!

            # ...make sure the summary reflects the change
            self.updated_date_gmt = Time.now.utc
            save!
        end
    end

    def self.create_sample_lists()
        # Tiny test list
        ranges = []
        ranges << {from: "B 5180", to: "B 5224", name: "Philosophy (General) / East Asia"}
        ranges << {from: "GV 712", to: "GV 715", name: "Something something"}
        self.create_sample_list("Tiny test list", ranges)

        # Econ Pilot
        ranges = []
        ranges << {from: "HB", to: "HB", name: ""}
        ranges << {from: "HC", to: "HC", name: ""}
        ranges << {from: "HD", to: "HD", name: ""}
        ranges << {from: "HE", to: "HE", name: ""}
        ranges << {from: "HF", to: "HF", name: ""}
        ranges << {from: "HG", to: "HG", name: ""}
        ranges << {from: "HJ", to: "HJ", name: ""}
        ranges << {from: "LC 65", to: "LC 70", name: ""}
        ranges << {from: "QA 269", to: "QA 272", name: ""}
        ranges << {from: "S 560", to: "S 582", name: ""}
        ranges << {from: "T 56.8", to: "T 58.3", name: ""}
        ranges << {from: "GV 712", to: "GV 715", name: ""}
        ranges << {from: "GV 716", to: "GV 716", name: ""}
        ranges << {from: "SB 107", to: "SB 112", name: ""}
        self.create_sample_list("ECON Pilot", ranges)

        # GOBI EA_review
        ranges = []
        ranges << {from: "B 125", to: "B 162", name: "Philosophy (General) / Orient"}
        ranges << {from: "B 5180", to: "B 5224", name: "Philosophy (General) / East Asia"}
        ranges << {from: "B 5230", to: "B 5234", name: "Philosophy (General) / korea"}
        ranges << {from: "B 5240", to: "B 5244", name: "Philosophy (General) / Japan"}
        ranges << {from: "B 5250", to: "B 5254", name: "Philosophy (General) / Korea"}
        ranges << {from: "BF 1779", to: "BF 1779", name: "Psychology / Feng shui"}
        ranges << {from: "BL 1000", to: "BL 2370", name: "Religion / Asian.  Oriental"}
        ranges << {from: "BL 1830", to: "BL 1945", name: "Religion / Confucianism-Taoism"}
        ranges << {from: "BL 2216", to: "BL 2229", name: "Religion / Shinto"}
        ranges << {from: "BR 731", to: "BR 1599", name: "Christianity / History by region or country"}
        ranges << {from: "CD 5001", to: "CD 6471", name: "Diplomatics.  Archives.  Seals / Seals"}
        ranges << {from: "CE 1", to: "CE 97", name: "Technical Chronology.  Calendar / Technical Chronology.  Calendar"}
        ranges << {from: "CJ 1", to: "CJ 6661", name: "Numismatics / Numismatics"}
        ranges << {from: "CN 900", to: "CN 1355", name: "Inscriptions.  Epigraphy / By region or country"}
        ranges << {from: "CS 2300", to: "CS 3090", name: "Genealogy / Personal and family names"}
        ranges << {from: "CT 759", to: "CT 3199", name: "Biography / National biography"}
        ranges << {from: "DS 501", to: "DS 519", name: "Asia / Eastern Asia.  Far East."}
        ranges << {from: "DS 701", to: "DS 800", name: "Asia / China"}
        ranges << {from: "DS 801", to: "DS 900", name: "Asia / Japan"}
        ranges << {from: "DS 901", to: "DS 937", name: "Asia / Korea"}
        ranges << {from: "GB 170.3", to: "GB 399", name: "Physical Geography / By region or country"}
        ranges << {from: "GF 651", to: "GF 700", name: "Human Ecology.  Anthropogeography / Asia"}
        ranges << {from: "GN 590", to: "GN 642", name: "Anthropology / Asian ethnic groups"}
        ranges << {from: "GR 265", to: "GR 349", name: "Folklore / Folklore of Asia"}
        ranges << {from: "GT 1370", to: "GT 1579", name: "Manners and Customs (General) / Clothing of Asia"}
        ranges << {from: "HB 125", to: "HB 126", name: "Economic Theory. Demography / Asia"}
        ranges << {from: "HC 411", to: "HC 470", name: "Economic History and Conditions / Asia"}
        ranges << {from: "J 500", to: "J 703", name: "General Legislative and Executive Papers / Asia"}
        ranges << {from: "JQ 670", to: "JQ 679", name: "Political Institutions and Public Administration: Asia. Africa.  Australia / Hong Kong"}
        ranges << {from: "JQ 1050", to: "JQ 1061", name: "Political Institutions and Public Administration: Asia. Africa.  Australia / Goa.  Macau"}
        ranges << {from: "JQ 1500", to: "JQ 1519", name: "Political Institutions and Public Administration: Asia. Africa.  Australia / China"}
        ranges << {from: "JQ 1520", to: "JQ 1539", name: "Political Institutions and Public Administration: Asia. Africa.  Australia / Taiwan"}
        ranges << {from: "JQ 1600", to: "JQ 1699", name: "Political Institutions and Public Administration: Asia. Africa.  Australia / Japan"}
        ranges << {from: "JQ 1720", to: "JQ 1729", name: "Political Institutions and Public Administration: Asia. Africa.  Australia / Korea"}
        ranges << {from: "KNN 0", to: "KNN 9999", name: "South Asia.  Southeast Asia.  East Asia / China (to 1949)"}
        ranges << {from: "KNP 0", to: "KNP 499", name: "South Asia.  Southeast Asia.  East Asia / Taiwan"}
        ranges << {from: "KNQ 0", to: "KNQ 9999", name: "South Asia.  Southeast Asia.  East Asia / China (People's Republic)"}
        ranges << {from: "KNX 0", to: "KNX 4999", name: "South Asia.  Southeast Asia.  East Asia / Japan"}
        ranges << {from: "KNY 10", to: "KNY 220", name: "South Asia.  Southeast Asia.  East Asia / Japan (Cities, communities, etc.)"}
        ranges << {from: "KPA 0", to: "KPA 4999", name: "South Asia.  Southeast Asia.  East Asia / South Korea"}
        ranges << {from: "KPC 0", to: "KPC 4999", name: "South Asia.  Southeast Asia.  East Asia / North Korea"}
        ranges << {from: "LA 1050", to: "LA 1429", name: "History of Education / Asia"}
        ranges << {from: "LG 1", to: "LG 400", name: "Education - Individual Institutions / Asia"}
        ranges << {from: "ML 330", to: "ML 345", name: "Literature on Music / Asia"}
        ranges << {from: "PL 1", to: "PL 8844", name: "Languages and Literatures of Eastern Asia, Africa, Oceania / Languages and Literatures of Eastern Asia, Africa, Oceania"}
        ranges << {from: "PL 491", to: "PL 5000", name: "Languages and Literatures of Eastern Asia, Africa, Oceania / Far Eastern languages and literatures"}
        ranges << {from: "PL 501", to: "PL 898", name: "Languages and Literatures of Eastern Asia, Africa, Oceania / Japanese"}
        ranges << {from: "PL 501", to: "PL 699", name: "Languages and Literatures of Eastern Asia, Africa, Oceania / Language"}
        ranges << {from: "PL 701", to: "PL 898", name: "Languages and Literatures of Eastern Asia, Africa, Oceania / Literature"}
        ranges << {from: "PL 901", to: "PL 998", name: "Languages and Literatures of Eastern Asia, Africa, Oceania / Korean"}
        ranges << {from: "PL 901", to: "PL 949", name: "Languages and Literatures of Eastern Asia, Africa, Oceania / Language"}
        ranges << {from: "PL 950", to: "PL 998", name: "Languages and Literatures of Eastern Asia, Africa, Oceania / Literature"}
        ranges << {from: "PL 1001", to: "PL 3279", name: "Languages and Literatures of Eastern Asia, Africa, Oceania / Chinese"}
        ranges << {from: "PL 1001", to: "PL 2239", name: "Languages and Literatures of Eastern Asia, Africa, Oceania / Language"}
        ranges << {from: "PL 2250", to: "PL 3300", name: "Languages and Literatures of Eastern Asia, Africa, Oceania / Literature"}
        ranges << {from: "PL 3301", to: "PL 5000", name: "Languages and Literatures of Eastern Asia, Africa, Oceania / Other groups"}
        ranges << {from: "PN 1995.9.K35", to: "PN 1995.9.K35", name: "Literature: General and Universal Literary History / Kanagawa-ken (Japan)"}
        ranges << {from: "PN 1995.9.K95", to: "PN 1995.9.K95", name: "Literature: General and Universal Literary History / Kyushu Region (Japan)"}
        ranges << {from: "Z 787", to: "Z 1000", name: "Bibliography.  Library Science / Libraries"}
        ranges << {from: "Z 1946", to: "Z 6953.7", name: "Bibliography.  Library Science / Bibliography.  Books and reading"}
        self.create_sample_list("GOBI--2020_01_LC Subject Grouping_EA_review", ranges)


    end

    def self.create_sample_list(name, ranges)
        s = EcoSummary.new
        s.list_name = name
        s.save!

        ranges.each do |range|
            r = EcoRange.new
            r.eco_summary_id = s.id
            r.from = range[:from]
            r.to = range[:to]
            r.name = range[:name]
            r.save!
        end

        # Populate it with the bib information for the ranges
        # s.refresh()
    end
end