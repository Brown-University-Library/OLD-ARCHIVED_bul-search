class CreateEcoRanges < ActiveRecord::Migration
    def change
      create_table :eco_ranges do |t|
        t.integer :eco_summary_id
        t.string :name
        t.string :from
        t.string :to
        t.integer :count
      end

      add_index :eco_ranges, [:eco_summary_id]
    end
  end
