class EcoRange < ActiveRecord::Base
    def name_display
        if name != nil && name.strip != ""
            return name
        end
        "--"
    end

    def percent(total)
        return 0 if count == nil
        (count * 100) / total
    end

    def percent_bar(total)
        num = percent(total)
        return "" if num == 0
        "".ljust(num, "X")
    end
end