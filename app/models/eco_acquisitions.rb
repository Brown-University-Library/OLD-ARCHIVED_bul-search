class EcoAcquisitions < ActiveRecord::Base
    def percent(total)
        return 0 if total == 0
        (self.total * 100) / total
    end
end