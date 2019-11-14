class AddColumnsToEcoDetails < ActiveRecord::Migration
    def change
        add_column :eco_details, :ord_record_num, :integer
        add_column :eco_details, :fund_code, :string
        add_column :eco_details, :fund_code_num, :integer
        add_column :eco_details, :fund_code_master, :string

        add_index :eco_details, [:fund_code]
        add_index :eco_details, [:fund_code_master]
    end
  end
