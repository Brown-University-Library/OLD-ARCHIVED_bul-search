class AddIndexToSearches < ActiveRecord::Migration
  def change
    add_index :searches, [:created_at]
  end
end
