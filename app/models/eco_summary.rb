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
        # TODO: add ranges
        ranges.each do |range|
            r = EcoRange.new
            r.eco_summary_id = s.id
            r.from = range[:from]
            r.to = range[:to]
            r.save!
        end
    end
end