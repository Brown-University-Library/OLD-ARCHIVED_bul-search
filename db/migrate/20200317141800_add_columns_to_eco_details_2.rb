class AddColumnsToEcoDetails2 < ActiveRecord::Migration
    def change
        add_column :eco_details, :eco_summary_id, :integer

        add_index :eco_details, [:eco_summary_id]
    end
  end
