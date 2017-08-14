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

ActiveRecord::Schema.define(version: 20170809114055) do

  create_table "bookmarks", force: true do |t|
    t.integer  "user_id",       null: false
    t.string   "user_type"
    t.string   "document_id"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "document_type"
  end

  add_index "bookmarks", ["user_id"], name: "index_bookmarks_on_user_id", using: :btree

  create_table "callnumbers", force: true do |t|
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

  create_table "locations", force: true do |t|
    t.string   "code"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reserves_caches", force: true do |t|
    t.string "classid",       limit: 10
    t.string "name"
    t.string "number",        limit: 50
    t.string "section",       limit: 10
    t.string "number_search", limit: 60
    t.string "instructor"
    t.string "instructorid",  limit: 10
    t.string "semester",      limit: 50
    t.string "library",       limit: 50
  end

  add_index "reserves_caches", ["number", "section"], name: "index_reserves_caches_on_number_and_section", using: :btree

  create_table "searches", force: true do |t|
    t.text     "query_params"
    t.integer  "user_id"
    t.string   "user_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "searches", ["user_id"], name: "index_searches_on_user_id", using: :btree

  create_table "searches_params", force: true do |t|
    t.integer "search_id"
    t.string  "q"
    t.string  "search_field"
    t.string  "action"
    t.string  "controller"
    t.string  "sort"
    t.string  "utf8"
    t.string  "source"
    t.string  "f",                limit: 512
    t.string  "other_id"
    t.string  "op"
    t.string  "all_fields"
    t.string  "title"
    t.string  "subject"
    t.string  "publication_date"
    t.string  "f_inclusive",      limit: 512
    t.string  "format"
    t.string  "facet_page"
    t.string  "facet_sort"
    t.string  "isbn"
    t.string  "author"
    t.string  "range_end"
    t.string  "range_field"
    t.string  "range_start"
    t.string  "limit"
    t.string  "range"
    t.string  "rows"
    t.string  "x_field"
    t.string  "f_author_facet"
    t.string  "f_building_facet"
    t.string  "f_language_facet"
    t.string  "f_topic_facet"
    t.string  "f_access_facet"
    t.string  "f_format"
    t.string  "f_region_facet"
    t.string  "range_pub_date"
    t.string  "isbn_t"
    t.string  "callnumber"
    t.string  "callnumber_t"
    t.string  "task"
    t.string  "location_code"
    t.string  "location_code_t"
    t.string  "file"
    t.string  "bookplate_code"
    t.string  "loc"
    t.string  "loc_code"
    t.string  "loccode"
  end

  add_index "searches_params", ["q"], name: "index_searches_params_on_q", using: :btree
  add_index "searches_params", ["search_id"], name: "index_searches_params_on_search_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "guest",                  default: false
    t.string   "provider"
    t.string   "uid"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
