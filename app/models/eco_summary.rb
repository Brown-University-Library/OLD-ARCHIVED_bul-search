class EcoSummary < ActiveRecord::Base

    def updated_date
        self.updated_date_gmt.localtime
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
end