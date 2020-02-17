class EcoSummary < ActiveRecord::Base

    def updated_date
        self.updated_date_gmt.localtime
    end

    def fund_codes
        @fund_codes ||= begin
            JSON.parse(self.fundcodes_str || "[]")
        end
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