class AddColumnsToEcoSummaries2 < ActiveRecord::Migration
    def change
        add_column :eco_summaries, :buildings_allowed, :text
    end
  end
