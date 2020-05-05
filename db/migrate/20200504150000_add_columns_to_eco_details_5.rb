class AddColumnsToEcoDetails5 < ActiveRecord::Migration
    def change
        add_column :eco_details, :format, :string
        add_column :eco_details, :is_online, :boolean, default: false
    end
end
