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
            data = Callnumber.get_by_range(range.from, range.to)
            data.each do |row|
                EcoDetails.new_from_bib(id, row[:id])
            end
        end
    end

    def self.create_sample_lists()
        create_sample_list_1()
        create_sample_list_2()
    end

    def self.create_sample_list_1()
        s = EcoSummary.new
        s.list_name = "List One"
        s.save!

        ranges = []
        ranges << {from: "NA 028000D800", to: "NA 9999"}
        ranges << {from: "PQ 809812O380A122 000 2009", to: "PQ 9999"}
        ranges.each do |range|
            r = EcoRange.new
            r.eco_summary_id = s.id
            r.from = range[:from]
            r.to = range[:to]
            r.save!
        end
    end

    def self.create_sample_list_2()
        s = EcoSummary.new
        s.list_name = "GOBI--2020_01_LC Subject Grouping_EA_review"
        s.save!

        ranges = []
        ranges << {from: "B 125", to: "B 162"}
        ranges << {from: "B 5180", to: "B 5224"}
        ranges << {from: "B 5230", to: "B 5234"}
        ranges << {from: "B 5240", to: "B 5244"}
        ranges << {from: "B 5250", to: "B 5254"}
        ranges << {from: "BF 1779", to: "BF "}
        ranges << {from: "BL 1000", to: "BL 2370"}
        ranges << {from: "BL 1830", to: "BL 1945"}
        ranges << {from: "BL 2216", to: "BL 2229"}
        ranges << {from: "BR 731", to: "BR 1599"}
        ranges << {from: "CD 5001", to: "CD 6471"}
        ranges << {from: "CE 1", to: "CE 97"}
        ranges << {from: "CJ 1", to: "CJ 6661"}
        ranges << {from: "CN 900", to: "CN 1355"}
        ranges << {from: "CS 2300", to: "CS 3090"}
        ranges << {from: "CT 759", to: "CT 3199"}
        ranges << {from: "DS 501", to: "DS 519"}
        ranges << {from: "DS 701", to: "DS 800"}
        ranges << {from: "DS 801", to: "DS 900"}
        ranges << {from: "DS 901", to: "DS 937"}
        ranges << {from: "GB 170.3", to: "GB 399"}
        ranges << {from: "GF 651", to: "GF 700"}
        ranges << {from: "GN 590", to: "GN 642"}
        ranges << {from: "GR 265", to: "GR 349"}
        ranges << {from: "GT 1370", to: "GT 1579"}
        ranges << {from: "HB 125", to: "HB 126"}
        ranges << {from: "HC 411", to: "HC 470"}
        ranges << {from: "J 500", to: "J 703"}
        ranges << {from: "JQ 670", to: "JQ 679"}
        ranges << {from: "JQ 1050", to: "JQ 1061"}
        ranges << {from: "JQ 1500", to: "JQ 1519"}
        ranges << {from: "JQ 1520", to: "JQ 1539"}
        ranges << {from: "JQ 1600", to: "JQ 1699"}
        ranges << {from: "JQ 1720", to: "JQ 1729"}
        ranges << {from: "LA 1050", to: "LA 1429"}
        ranges << {from: "LG 1", to: "LG 400"}
        ranges << {from: "ML 330", to: "ML 345"}
        ranges << {from: "PL 1", to: "PL 8844"}
        ranges << {from: "PL 491", to: "PL 5000"}
        ranges << {from: "PL 501", to: "PL 898"}
        ranges << {from: "PL 501", to: "PL 699"}
        ranges << {from: "PL 701", to: "PL 898"}
        ranges << {from: "PL 901", to: "PL 998"}
        ranges << {from: "PL 901", to: "PL 949"}
        ranges << {from: "PL 950", to: "PL 998"}
        ranges << {from: "PL 1001", to: "PL 3279"}
        ranges << {from: "PL 1001", to: "PL 2239"}
        ranges << {from: "PL 2250", to: "PL 3300"}
        ranges << {from: "PL 3301", to: "PL 5000"}
        ranges << {from: "Z 787", to: "Z 1000"}
        ranges << {from: "Z 1946", to: "Z 6953.7"}
        ranges.each do |range|
            r = EcoRange.new
            r.eco_summary_id = s.id
            r.from = range[:from]
            r.to = range[:to]
            r.save!
        end
    end
end