class CreateCallnumbers < ActiveRecord::Migration
  def change
    create_table :callnumbers do |t|
      t.string :original, limit: 30
      t.string :normalized, limit: 50
      t.string :bib, limit: 10

      t.timestamps
    end
    add_index :callnumbers, :original
    add_index :callnumbers, :normalized
    add_index :callnumbers, :bib
  end
end
