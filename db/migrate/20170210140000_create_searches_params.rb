class CreateSearchesParams < ActiveRecord::Migration
  def change
    create_table :searches_params do |t|
      t.integer :search_id
      t.string :q, limit: 255
      t.string :search_field, limit: 255
      t.string :action, limit: 255
      t.string :controller, limit: 255
      t.string :sort, limit: 255
      t.string :utf8, limit: 255
      t.string :source, limit: 255
      t.string :f, limit: 512
      t.string :other_id, limit: 255 # id on data
      t.string :op, limit: 255
      t.string :all_fields, limit: 255
      t.string :title, limit: 255
      t.string :subject, limit: 255
      t.string :publication_date, limit: 255
      t.string :f_inclusive, limit: 512
      t.string :format, limit: 255
      t.string :facet_page, limit: 255
      t.string :facet_sort, limit: 255
      t.string :isbn, limit: 255
      t.string :author, limit: 255
      t.string :range_end, limit: 255
      t.string :range_field, limit: 255
      t.string :range_start, limit: 255
      t.string :limit, limit: 255
      t.string :range, limit: 255
      t.string :rows, limit: 255
      t.string :x_field, limit: 255
      t.string :f_author_facet, limit: 255
      t.string :f_building_facet, limit: 255
      t.string :f_language_facet, limit: 255
      t.string :f_topic_facet, limit: 255
      t.string :f_access_facet, limit: 255
      t.string :f_format, limit: 255
      t.string :f_region_facet, limit: 255
      t.string :range_pub_date, limit: 255
      t.string :range_pub_date, limit: 255
      t.string :isbn_t, limit: 255
      t.string :callnumber, limit: 255
      t.string :callnumber_t, limit: 255
      t.string :task, limit: 255
      t.string :location_code, limit: 255
      t.string :location_code_t, limit: 255
      t.string :publication_date, limit: 255
      t.string :file, limit: 255
      t.string :bookplate_code, limit: 255
      t.string :loc, limit: 255
      t.string :loc_code, limit: 255
      t.string :loccode, limit: 255
    end

    add_index :searches_params, :search_id
    add_index :searches_params, :q
  end
end
