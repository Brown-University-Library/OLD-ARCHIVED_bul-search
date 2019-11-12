class CreateEcoDetails < ActiveRecord::Migration
    def change
      create_table :eco_details do |t|
        t.integer :sierra_list
        t.integer :bib_record_num
        t.string :record_type_code, limit: 1
        t.integer :bib_id, limit: 5           # bigint
        t.string :title, limit:1000
        t.string :language_code, limit: 3
        t.string :b_code1, limit: 1
        t.string :b_code2, limit: 3
        t.string :b_code3, limit: 1
        t.string :country_code, limit: 3
        t.boolean :is_course_reserve, default: false
        t.datetime :cataloging_date_gmt
        t.datetime :creation_date_gmt
        t.integer :publish_year
        t.string :author, limit: 1000
        t.integer :item_record_num
        t.string :item_type_code, limit: 1
        t.string :barcode, limit: 1000
        t.string :i_code2, limit: 1
        t.integer :i_type_code_num
        t.string :location_code, limit: 5
        t.string :item_status_code, limit: 3
        t.datetime :last_checkin_gmt
        t.integer :checkout_total
        t.integer :renewal_total
        t.integer :last_year_to_date_checkout_total
        t.integer :year_to_date_checkout_total
        t.integer :copy_num
        t.integer :checkout_statistic_group_code_num
        t.integer :use3_count
        t.datetime :last_checkout_gmt
        t.integer :internal_use_count
        t.integer :copy_use_count
        t.string :old_location_code, limit: 5
        t.boolean :is_suppressed, default: false
        t.datetime :item_creation_date_gmt
        t.string :callnumber_raw, limit: 1000
        t.string :callnumber_norm, limit: 1000
        t.text :publisher
        t.string :marc_tag, limit: 3
        t.text :marc_value
      end

      add_index :eco_details, [:sierra_list, :bib_record_num]
      add_index :eco_details, [:callnumber_norm]
    end
  end
