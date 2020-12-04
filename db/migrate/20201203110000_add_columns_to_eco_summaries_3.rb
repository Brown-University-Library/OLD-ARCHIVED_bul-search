class AddColumnsToEcoSummaries3 < ActiveRecord::Migration
  def change
      add_column :eco_summaries, :tags, :text
  end
end
