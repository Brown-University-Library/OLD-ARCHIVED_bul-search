class EcoRange < ActiveRecord::Base
    def name_display
        if name != nil && name.strip != ""
            return name
        end
        "--"
    end
end