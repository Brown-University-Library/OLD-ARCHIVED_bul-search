class EcoTags < ActiveRecord::Base
    def self.names_sorted
        @names_sorted ||= self.select(:name).order(:name).map {|r| r["name"]}
    end
end