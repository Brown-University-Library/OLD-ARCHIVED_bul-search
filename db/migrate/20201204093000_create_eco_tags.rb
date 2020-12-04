class CreateEcoTags < ActiveRecord::Migration
    def change
      create_table :eco_tags do |t|
        t.string :name
      end

      add_index :eco_tags, [:name]
    end
  end
