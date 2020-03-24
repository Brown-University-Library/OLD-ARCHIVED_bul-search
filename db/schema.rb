# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20200319140000) do

  create_table "best_bet_entries", force: :cascade do |t|
    t.string "name",        limit: 255
    t.string "database",    limit: 255
    t.text   "queries",     limit: 65535
    t.text   "url",         limit: 65535
    t.text   "description", limit: 65535
  end

  add_index "best_bet_entries", ["name"], name: "index_best_bet_entries_on_name", using: :btree

  create_table "best_bet_terms", force: :cascade do |t|
    t.integer "best_bet_entry_id", limit: 4
    t.string  "term",              limit: 255
  end

  add_index "best_bet_terms", ["best_bet_entry_id"], name: "index_best_bet_terms_on_best_bet_entry_id", using: :btree
  add_index "best_bet_terms", ["term"], name: "index_best_bet_terms_on_term", using: :btree

  create_table "bookmarks", force: :cascade do |t|
    t.integer  "user_id",       limit: 4,   null: false
    t.string   "user_type",     limit: 255
    t.string   "document_id",   limit: 255
    t.string   "title",         limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "document_type", limit: 255
  end

  add_index "bookmarks", ["user_id"], name: "index_bookmarks_on_user_id", using: :btree

  create_table "callnumbers", force: :cascade do |t|
    t.string   "original",   limit: 100
    t.string   "normalized", limit: 100
    t.string   "bib",        limit: 10
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "callnumbers", ["bib", "original"], name: "index_callnumbers_on_bib_and_original", unique: true, using: :btree
  add_index "callnumbers", ["bib"], name: "index_callnumbers_on_bib", using: :btree
  add_index "callnumbers", ["normalized"], name: "index_callnumbers_on_normalized", using: :btree
  add_index "callnumbers", ["original"], name: "index_callnumbers_on_original", using: :btree

  create_table "eco_details", force: :cascade do |t|
    t.integer  "sierra_list",                       limit: 4
    t.integer  "bib_record_num",                    limit: 4
    t.string   "record_type_code",                  limit: 1
    t.integer  "bib_id",                            limit: 8
    t.string   "title",                             limit: 1000
    t.string   "language_code",                     limit: 3
    t.string   "b_code1",                           limit: 1
    t.string   "b_code2",                           limit: 3
    t.string   "b_code3",                           limit: 1
    t.string   "country_code",                      limit: 3
    t.boolean  "is_course_reserve",                               default: false
    t.datetime "cataloging_date_gmt"
    t.datetime "creation_date_gmt"
    t.integer  "publish_year",                      limit: 4
    t.string   "author",                            limit: 1000
    t.integer  "item_record_num",                   limit: 4
    t.string   "item_type_code",                    limit: 1
    t.string   "barcode",                           limit: 1000
    t.string   "i_code2",                           limit: 1
    t.integer  "i_type_code_num",                   limit: 4
    t.string   "location_code",                     limit: 5
    t.string   "item_status_code",                  limit: 3
    t.datetime "last_checkin_gmt"
    t.integer  "checkout_total",                    limit: 4
    t.integer  "renewal_total",                     limit: 4
    t.integer  "last_year_to_date_checkout_total",  limit: 4
    t.integer  "year_to_date_checkout_total",       limit: 4
    t.integer  "copy_num",                          limit: 4
    t.integer  "checkout_statistic_group_code_num", limit: 4
    t.integer  "use3_count",                        limit: 4
    t.datetime "last_checkout_gmt"
    t.integer  "internal_use_count",                limit: 4
    t.integer  "copy_use_count",                    limit: 4
    t.string   "old_location_code",                 limit: 5
    t.boolean  "is_suppressed",                                   default: false
    t.datetime "item_creation_date_gmt"
    t.string   "callnumber_raw",                    limit: 1000
    t.string   "callnumber_norm",                   limit: 1000
    t.text     "publisher",                         limit: 65535
    t.string   "marc_tag",                          limit: 3
    t.text     "marc_value",                        limit: 65535
    t.integer  "ord_record_num",                    limit: 4
    t.string   "fund_code",                         limit: 255
    t.integer  "fund_code_num",                     limit: 4
    t.string   "fund_code_master",                  limit: 255
    t.integer  "eco_summary_id",                    limit: 4
    t.integer  "eco_range_id",                      limit: 4
  end

  add_index "eco_details", ["callnumber_norm"], name: "index_eco_details_on_callnumber_norm", using: :btree
  add_index "eco_details", ["eco_range_id"], name: "index_eco_details_on_eco_range_id", using: :btree
  add_index "eco_details", ["eco_summary_id"], name: "index_eco_details_on_eco_summary_id", using: :btree
  add_index "eco_details", ["fund_code"], name: "index_eco_details_on_fund_code", using: :btree
  add_index "eco_details", ["fund_code_master"], name: "index_eco_details_on_fund_code_master", using: :btree
  add_index "eco_details", ["sierra_list", "bib_record_num"], name: "index_eco_details_on_sierra_list_and_bib_record_num", using: :btree

  create_table "eco_ranges", force: :cascade do |t|
    t.integer "eco_summary_id", limit: 4
    t.string  "name",           limit: 255
    t.string  "from",           limit: 255
    t.string  "to",             limit: 255
    t.integer "count",          limit: 4
  end

  add_index "eco_ranges", ["eco_summary_id"], name: "index_eco_ranges_on_eco_summary_id", using: :btree

  create_table "eco_summaries", force: :cascade do |t|
    t.integer  "sierra_list",      limit: 4
    t.string   "list_name",        limit: 255
    t.integer  "bib_count",        limit: 4
    t.integer  "item_count",       limit: 4
    t.text     "locations_str",    limit: 65535
    t.text     "callnumbers_str",  limit: 65535
    t.text     "checkouts_str",    limit: 65535
    t.text     "fundcodes_str",    limit: 65535
    t.text     "subjects_str",     limit: 65535
    t.datetime "updated_date_gmt"
  end

  add_index "eco_summaries", ["sierra_list"], name: "index_eco_summaries_on_sierra_list", using: :btree

  create_table "libguides_caches", force: :cascade do |t|
    t.string "name",       limit: 50
    t.string "url",        limit: 255
    t.string "guide_type", limit: 50
  end

  add_index "libguides_caches", ["guide_type", "name"], name: "index_libguides_caches_on_guide_type_and_name", using: :btree
  add_index "libguides_caches", ["name"], name: "index_libguides_caches_on_name", using: :btree

  create_table "locations", force: :cascade do |t|
    t.string   "code",       limit: 255
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reserves_caches", force: :cascade do |t|
    t.string "classid",       limit: 10
    t.string "name",          limit: 255
    t.string "number",        limit: 50
    t.string "section",       limit: 10
    t.string "number_search", limit: 60
    t.string "instructor",    limit: 255
    t.string "instructorid",  limit: 10
    t.string "semester",      limit: 50
    t.string "library",       limit: 50
  end

  add_index "reserves_caches", ["number", "section"], name: "index_reserves_caches_on_number_and_section", using: :btree

  create_table "searches", force: :cascade do |t|
    t.text     "query_params", limit: 65535
    t.integer  "user_id",      limit: 4
    t.string   "user_type",    limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "searches", ["created_at"], name: "index_searches_on_created_at", using: :btree
  add_index "searches", ["user_id"], name: "index_searches_on_user_id", using: :btree

  create_table "searches_params", force: :cascade do |t|
    t.integer "search_id",        limit: 4
    t.string  "q",                limit: 255
    t.string  "search_field",     limit: 255
    t.string  "action",           limit: 255
    t.string  "controller",       limit: 255
    t.string  "sort",             limit: 255
    t.string  "utf8",             limit: 255
    t.string  "source",           limit: 255
    t.string  "f",                limit: 512
    t.string  "other_id",         limit: 255
    t.string  "op",               limit: 255
    t.string  "all_fields",       limit: 255
    t.string  "title",            limit: 255
    t.string  "subject",          limit: 255
    t.string  "publication_date", limit: 255
    t.string  "f_inclusive",      limit: 512
    t.string  "format",           limit: 255
    t.string  "facet_page",       limit: 255
    t.string  "facet_sort",       limit: 255
    t.string  "isbn",             limit: 255
    t.string  "author",           limit: 255
    t.string  "range_end",        limit: 255
    t.string  "range_field",      limit: 255
    t.string  "range_start",      limit: 255
    t.string  "limit",            limit: 255
    t.string  "range",            limit: 255
    t.string  "rows",             limit: 255
    t.string  "x_field",          limit: 255
    t.string  "f_author_facet",   limit: 255
    t.string  "f_building_facet", limit: 255
    t.string  "f_language_facet", limit: 255
    t.string  "f_topic_facet",    limit: 255
    t.string  "f_access_facet",   limit: 255
    t.string  "f_format",         limit: 255
    t.string  "f_region_facet",   limit: 255
    t.string  "range_pub_date",   limit: 255
    t.string  "isbn_t",           limit: 255
    t.string  "callnumber",       limit: 255
    t.string  "callnumber_t",     limit: 255
    t.string  "task",             limit: 255
    t.string  "location_code",    limit: 255
    t.string  "location_code_t",  limit: 255
    t.string  "file",             limit: 255
    t.string  "bookplate_code",   limit: 255
    t.string  "loc",              limit: 255
    t.string  "loc_code",         limit: 255
    t.string  "loccode",          limit: 255
  end

  add_index "searches_params", ["q"], name: "index_searches_params_on_q", using: :btree
  add_index "searches_params", ["search_id"], name: "index_searches_params_on_search_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "",    null: false
    t.string   "encrypted_password",     limit: 255, default: "",    null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "guest",                              default: false
    t.string   "provider",               limit: 255
    t.string   "uid",                    limit: 255
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
