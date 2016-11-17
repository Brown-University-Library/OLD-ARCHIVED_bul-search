class CreateCallnumbers < ActiveRecord::Migration
  def change
    create_table :callnumbers do |t|
      t.string :original, limit: 100
      t.string :normalized, limit: 100
      t.string :bib, limit: 10

      t.timestamps
    end
    add_index :callnumbers, :original
    add_index :callnumbers, :normalized
    add_index :callnumbers, :bib

    # This index is used to detect duplicates when cacheing BIB/callnumbers
    add_index :callnumbers, [:bib, :original], :unique => true
  end
end
