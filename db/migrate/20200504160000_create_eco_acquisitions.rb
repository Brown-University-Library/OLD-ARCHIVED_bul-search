class CreateEcoAcquisitions < ActiveRecord::Migration
    def change
      create_table :eco_acquisitions do |t|
        t.integer :eco_summary_id
        t.string :acq_type
        t.integer :year
        t.integer :total
        t.integer :online
        t.integer :book
        t.integer :periodical
        t.integer :sound
        t.integer :video
        t.integer :score
        t.integer :etd
        t.integer :map
        t.integer :file
        t.integer :visual
        t.integer :archive
        t.integer :object
        t.integer :mixed
        t.integer :unknown
      end

      add_index :eco_acquisitions, [:eco_summary_id, :acq_type, :year]
    end
  end
