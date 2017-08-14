class CreateReservesCache < ActiveRecord::Migration
  def change
    create_table :reserves_caches do |t|
      t.string :classid, limit: 10
      t.string :name, limit: 255
      t.string :number, limit: 50
      t.string :section, limit: 10
      t.string :number_search, limit: 60
      t.string :instructor, limit: 255
      t.string :instructorid, limit: 10
      t.string :semester, limit: 50
      t.string :library, limit: 50
    end

    add_index :reserves_caches, [:number, :section]
  end
end
