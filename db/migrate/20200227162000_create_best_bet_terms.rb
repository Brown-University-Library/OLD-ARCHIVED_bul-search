class CreateBestBetTerms < ActiveRecord::Migration
    def change
      create_table :best_bet_terms do |t|
        t.integer :best_bet_entry_id
        t.string :term
      end

      add_index :best_bet_terms, [:best_bet_entry_id]
      add_index :best_bet_terms, [:term]
    end
  end
