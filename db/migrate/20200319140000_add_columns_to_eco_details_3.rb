class AddColumnsToEcoDetails3 < ActiveRecord::Migration
    def change
        add_column :eco_details, :eco_range_id, :integer

        add_index :eco_details, [:eco_range_id]
    end
  end
