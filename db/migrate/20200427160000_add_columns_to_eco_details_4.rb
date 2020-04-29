class AddColumnsToEcoDetails4 < ActiveRecord::Migration
    def change
        add_column :eco_details, :checkout_2015_plus, :integer
        add_column :eco_details, :item_create_date, :datetime
        add_column :eco_details, :bib_create_date, :datetime
        add_column :eco_details, :bib_catalog_date, :datetime
        add_column :eco_details, :subjects, :text
    end
  end
