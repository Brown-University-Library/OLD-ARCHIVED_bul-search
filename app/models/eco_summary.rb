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
        ranges << {from: "B  518000", to: "B  522400"}
        ranges << {from: "B  523000", to: "B  523400"}
        ranges << {from: "B  524000", to: "B  524400"}
        ranges << {from: "B  525000", to: "B  525400"}
        ranges << {from: "BF 177900", to: "BF 177900"}
        ranges << {from: "BL 100000", to: "BL 237000"}
        ranges << {from: "BL 183000", to: "BL 194500"}
        ranges << {from: "BL 221600", to: "BL 222900"}
        ranges << {from: "BR 073100", to: "BR 159900"}
        ranges << {from: "CD 500100", to: "CD 647100"}
        ranges << {from: "CE 000100", to: "CE 009700"}
        ranges << {from: "CJ 000100", to: "CJ 666100"}
        ranges << {from: "CN 090000", to: "CN 135500"}
        ranges << {from: "CS 230000", to: "CS 309000"}
        ranges << {from: "CT 075900", to: "CT 319900"}
        ranges << {from: "DS 050100", to: "DS 051900"}
        ranges << {from: "DS 070100", to: "DS 080000"}
        ranges << {from: "DS 080100", to: "DS 090000"}
        ranges << {from: "DS 090100", to: "DS 093700"}
        ranges << {from: "GB 017003", to: "GB 039900"}
        ranges << {from: "GF 065100", to: "GF 070000"}
        ranges << {from: "GN 059000", to: "GN 064200"}
        ranges << {from: "GR 026500", to: "GR 034900"}
        ranges << {from: "GT 137000", to: "GT 157900"}
        ranges << {from: "HB 012500", to: "HB 012600"}
        ranges << {from: "HC 041100", to: "HC 047000"}
        ranges << {from: "J  050000", to: "J  070300"}
        ranges << {from: "JQ 067000", to: "JQ 067900"}
        ranges << {from: "JQ 105000", to: "JQ 106100"}
        ranges << {from: "JQ 150000", to: "JQ 151900"}
        ranges << {from: "JQ 152000", to: "JQ 153900"}
        ranges << {from: "JQ 160000", to: "JQ 169900"}
        ranges << {from: "JQ 172000", to: "JQ 172900"}
        ranges << {from: "LA 105000", to: "LA 142900"}
        ranges << {from: "LG 000100", to: "LG 040000"}
        ranges << {from: "ML 033000", to: "ML 034500"}
        ranges << {from: "PL 000100", to: "PL 884400"}
        ranges << {from: "PL 049100", to: "PL 500000"}
        ranges << {from: "PL 050100", to: "PL 089800"}
        ranges << {from: "PL 050100", to: "PL 069900"}
        ranges << {from: "PL 070100", to: "PL 089800"}
        ranges << {from: "PL 090100", to: "PL 099800"}
        ranges << {from: "PL 090100", to: "PL 094900"}
        ranges << {from: "PL 095000", to: "PL 099800"}
        ranges << {from: "PL 100100", to: "PL 327900"}
        ranges << {from: "PL 100100", to: "PL 223900"}
        ranges << {from: "PL 225000", to: "PL 330000"}
        ranges << {from: "PL 330100", to: "PL 500000"}
        ranges << {from: "Z  078700", to: "Z  100000"}
        ranges << {from: "Z  194600", to: "Z  695307"}
        ranges.each do |range|
            r = EcoRange.new
            r.eco_summary_id = s.id
            r.from = range[:from]
            r.to = range[:to]
            r.save!
        end
    end
end