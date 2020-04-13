class AddColumnsToEcoRanges < ActiveRecord::Migration
    def change
        add_column :eco_ranges, :bib_count, :integer
        add_column :eco_ranges, :item_count, :integer
    end
  end
