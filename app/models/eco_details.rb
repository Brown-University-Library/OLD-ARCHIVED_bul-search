class EcoDetails < ActiveRecord::Base
    def josiah_bib_id
        "b#{bib_record_num}"
    end
end