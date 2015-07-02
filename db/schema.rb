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

ActiveRecord::Schema.define(version: 20150702130718) do

  create_table "admission_volumes", force: true do |t|
    t.integer  "campaign_id"
    t.integer  "education_level_id", default: 11
    t.integer  "course",             default: 1
    t.integer  "direction_id"
    t.integer  "number_budget_o",    default: 0
    t.integer  "number_budget_oz",   default: 0
    t.integer  "number_budget_z",    default: 0
    t.integer  "number_paid_o",      default: 0
    t.integer  "number_paid_oz",     default: 0
    t.integer  "number_paid_z",      default: 0
    t.integer  "number_target_o",    default: 0
    t.integer  "number_target_oz",   default: 0
    t.integer  "number_target_z",    default: 0
    t.integer  "number_quota_o",     default: 0
    t.integer  "number_quota_oz",    default: 0
    t.integer  "number_quota_z",     default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admission_volumes", ["campaign_id"], name: "index_admission_volumes_on_campaign_id", using: :btree

  create_table "applications", force: true do |t|
    t.integer  "application_number"
    t.integer  "campaign_id"
    t.string   "entrant_last_name"
    t.string   "entrant_first_name"
    t.string   "entrant_middle_name"
    t.integer  "target_speciality_id"
    t.integer  "target_organization_id"
    t.integer  "nationality_type_id"
    t.integer  "region_id"
    t.integer  "gender_id"
    t.date     "birth_date"
    t.boolean  "need_hostel",            default: false
    t.boolean  "special_entrant",        default: false
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

  create_table "campaign_dates", force: true do |t|
    t.integer  "course",              default: 1
    t.integer  "education_level_id",  default: 5
    t.integer  "education_form_id",   default: 11
    t.integer  "education_source_id"
    t.integer  "stage"
    t.date     "date_start"
    t.date     "date_end"
    t.date     "date_order"
    t.integer  "campaign_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "campaign_dates", ["campaign_id"], name: "index_campaign_dates_on_campaign_id", using: :btree

  create_table "campaigns", force: true do |t|
    t.string   "name",        default: ""
    t.integer  "year_start"
    t.integer  "year_end"
    t.integer  "status_id",   default: 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_for_krym", default: false
  end

  create_table "competition_items", force: true do |t|
    t.string   "name",                      default: ""
    t.integer  "finance_source_id"
    t.integer  "competitive_group_id"
    t.integer  "competitive_group_item_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "competitions", force: true do |t|
    t.integer  "application_id"
    t.integer  "competition_item_id"
    t.integer  "priority"
    t.date     "admission_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "recommended_date"
  end

  add_index "competitions", ["application_id"], name: "index_competitions_on_application_id", using: :btree
  add_index "competitions", ["competition_item_id"], name: "index_competitions_on_competition_item_id", using: :btree

  create_table "competitive_group_items", force: true do |t|
    t.integer  "competitive_group_id"
    t.integer  "education_level_id",   default: 5
    t.integer  "direction_id"
    t.integer  "number_budget_o",      default: 0
    t.integer  "number_budget_oz",     default: 0
    t.integer  "number_budget_z",      default: 0
    t.integer  "number_paid_o",        default: 0
    t.integer  "number_paid_oz",       default: 0
    t.integer  "number_paid_z",        default: 0
    t.integer  "number_target_o",      default: 0
    t.integer  "number_target_oz",     default: 0
    t.integer  "number_target_z",      default: 0
    t.integer  "number_quota_o",       default: 0
    t.integer  "number_quota_oz",      default: 0
    t.integer  "number_quota_z",       default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "competitive_group_items", ["competitive_group_id"], name: "index_competitive_group_items_on_competitive_group_id", using: :btree

  create_table "competitive_group_target_items", force: true do |t|
    t.integer  "target_organization_id"
    t.integer  "education_level_id",     default: 5
    t.integer  "number_target_o",        default: 0
    t.integer  "number_target_oz",       default: 0
    t.integer  "number_target_z",        default: 0
    t.integer  "direction_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "competitive_group_id"
  end

  add_index "competitive_group_target_items", ["competitive_group_id"], name: "index_competitive_group_target_items_on_competitive_group_id", using: :btree
  add_index "competitive_group_target_items", ["target_organization_id"], name: "index_competitive_group_target_items_on_target_organization_id", using: :btree

  create_table "competitive_groups", force: true do |t|
    t.integer  "campaign_id"
    t.integer  "course",      default: 1
    t.string   "name",        default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "competitive_groups", ["campaign_id"], name: "index_competitive_groups_on_campaign_id", using: :btree

  create_table "education_document_types", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "education_documents", force: true do |t|
    t.integer  "application_id"
    t.integer  "education_document_type_id"
    t.string   "education_document_series"
    t.string   "education_document_number"
    t.date     "education_document_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "education_documents", ["application_id"], name: "index_education_documents_on_application_id", using: :btree
  add_index "education_documents", ["education_document_type_id"], name: "index_education_documents_on_education_document_type_id", using: :btree

  create_table "entrance_test_items", force: true do |t|
    t.integer  "competitive_group_id"
    t.integer  "entrance_test_type_id",  default: 1
    t.string   "form",                   default: ""
    t.integer  "min_score"
    t.integer  "entrance_test_priority"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "subject_id"
  end

  create_table "identity_document_types", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "identity_documents", force: true do |t|
    t.integer  "application_id"
    t.integer  "identity_document_type_id"
    t.string   "identity_document_series"
    t.string   "identity_document_number"
    t.date     "identity_document_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "identity_documents", ["application_id"], name: "index_identity_documents_on_application_id", using: :btree
  add_index "identity_documents", ["identity_document_type_id"], name: "index_identity_documents_on_identity_document_type_id", using: :btree

  create_table "institution_achievements", force: true do |t|
    t.string   "name"
    t.integer  "id_category"
    t.integer  "max_value"
    t.integer  "campaign_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "institution_achievements", ["campaign_id"], name: "index_institution_achievements_on_campaign_id", using: :btree

  create_table "queries", force: true do |t|
    t.string   "name",       default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "requests", force: true do |t|
    t.integer  "query_id"
    t.text     "input",      limit: 16777215
    t.text     "output",     limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "requests", ["query_id"], name: "index_requests_on_query_id", using: :btree

  create_table "target_organizations", force: true do |t|
    t.string   "target_organization_name", default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
