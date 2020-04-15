class AddColumnsToEcoSummaries < ActiveRecord::Migration
    def change
        add_column :eco_summaries, :description, :text
        add_column :eco_summaries, :status, :string
        add_column :eco_summaries, :refreshed_at, :datetime
        add_column :eco_summaries, :created_at, :datetime
        add_column :eco_summaries, :updated_at, :datetime
    end
  end
