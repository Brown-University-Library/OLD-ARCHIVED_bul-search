class CreateEcoSummaries < ActiveRecord::Migration
    def change
      create_table :eco_summaries do |t|
        t.integer :sierra_list
        t.string :list_name
        t.integer :bib_count
        t.integer :item_count
        t.text :locations_str
        t.text :callnumbers_str
        t.text :checkouts_str
        t.text :fundcodes_str
        t.text :subjects_str
        t.datetime :updated_date_gmt
      end

      add_index :eco_summaries, [:sierra_list]
    end
  end
