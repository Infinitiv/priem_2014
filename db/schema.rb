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

ActiveRecord::Schema.define(version: 20140623180650) do

  create_table "applications", force: true do |t|
    t.integer  "application_number"
    t.integer  "campaign_id"
    t.string   "entrant_last_name"
    t.string   "entrant_first_name"
    t.string   "entrant_middle_name"
    t.integer  "russian"
    t.integer  "chemistry"
    t.integer  "biology"
    t.integer  "target_speciality_id"
    t.integer  "target_organization_id"
    t.integer  "nationality_type_id"
    t.integer  "region_id"
    t.integer  "gender_id"
    t.date     "birth_date"
    t.boolean  "need_hostel",            default: false
    t.boolean  "special_entrant",        default: false
    t.boolean  "ege",                    default: false
    t.boolean  "ege_additional",         default: false
    t.boolean  "inner_exam",             default: false
    t.boolean  "olympionic",             default: false
    t.boolean  "benefit",                default: false
    t.date     "registration_date"
    t.date     "original_received_date"
    t.date     "last_deny_day"
    t.integer  "status_id",              default: 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "auth_data", force: true do |t|
    t.string   "login"
    t.string   "pass"
    t.integer  "institution_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "education_document_types", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "education_documents", force: true do |t|
    t.integer  "education_document_type_id"
    t.string   "series"
    t.string   "number"
    t.date     "date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "education_documents", ["education_document_type_id"], name: "index_education_documents_on_education_document_type_id", using: :btree

  create_table "identity_document_types", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "identity_documents", force: true do |t|
    t.integer  "identity_document_type_id"
    t.string   "series"
    t.string   "number"
    t.date     "date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "identity_documents", ["identity_document_type_id"], name: "index_identity_documents_on_identity_document_type_id", using: :btree

  create_table "queries", force: true do |t|
    t.string   "name",       default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "requests", force: true do |t|
    t.integer  "query_id"
    t.text     "input"
    t.text     "output"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "requests", ["query_id"], name: "index_requests_on_query_id", using: :btree

end
