class CreateLibguidesCache < ActiveRecord::Migration
  def change
    create_table :libguides_caches do |t|
      t.string :name, limit: 50
      t.string :url, limit: 255
      t.string :guide_type, limit: 50
    end

    add_index :libguides_caches, [:name]
    add_index :libguides_caches, [:guide_type, :name]
  end
end
