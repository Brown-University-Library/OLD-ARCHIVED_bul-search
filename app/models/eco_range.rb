class EcoRange < ActiveRecord::Base
    def name_display
        if name != nil && name.strip != ""
            return name
        end
        "--"
    end

    def summary
        @summary ||= EcoSummary.find(eco_summary_id)
    end

    def bib_percent
        total = (summary.bib_count || 0)
        return 0 if total == 0
        ((bib_count || 0) * 100) / total
    end

    def item_percent
        total = (summary.item_count || 0)
        return 0 if total == 0
        ((item_count || 0) * 100) / total
    end
end