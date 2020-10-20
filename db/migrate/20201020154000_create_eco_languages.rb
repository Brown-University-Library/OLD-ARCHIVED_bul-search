class CreateEcoLanguages < ActiveRecord::Migration
    def change
      create_table :eco_languages do |t|
        t.integer :eco_summary_id
        t.string :name
        t.integer :print
        t.integer :online
        t.integer :total
      end

      add_index :eco_languages, [:eco_summary_id]
    end
  end
