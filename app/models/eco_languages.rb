class EcoLanguages < ActiveRecord::Base
    def percent=(value)
        @percent = value
    end

    def percent()
        @percent
    end
end