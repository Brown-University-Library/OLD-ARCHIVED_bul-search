class CreateBestBetEntries < ActiveRecord::Migration
    def change
      create_table :best_bet_entries do |t|
        t.string :name
        t.string :database
        t.text :url
        t.text :description
      end

      add_index :best_bet_entries, [:name]
    end
  end
