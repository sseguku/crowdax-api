# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_07_16_234448) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "breaches", force: :cascade do |t|
    t.bigint "user_id"
    t.string "breach_type", null: false
    t.string "severity", null: false
    t.text "description", null: false
    t.datetime "detected_at", null: false
    t.datetime "resolved_at"
    t.string "status", default: "open"
    t.json "metadata"
    t.string "ip_address"
    t.string "user_agent"
    t.text "affected_data"
    t.integer "affected_records_count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["breach_type"], name: "index_breaches_on_breach_type"
    t.index ["detected_at"], name: "index_breaches_on_detected_at"
    t.index ["severity"], name: "index_breaches_on_severity"
    t.index ["status"], name: "index_breaches_on_status"
    t.index ["user_id"], name: "index_breaches_on_user_id"
  end

  create_table "campaigns", force: :cascade do |t|
    t.string "title"
    t.string "sector"
    t.decimal "goal_amount"
    t.string "pitch_deck"
    t.text "team"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.decimal "current_amount"
    t.string "campaign_status"
    t.decimal "raised_amount"
    t.index ["user_id"], name: "index_campaigns_on_user_id"
  end

  create_table "data_deletion_requests", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "requested_at", null: false
    t.text "reason"
    t.string "status", default: "pending"
    t.datetime "processed_at"
    t.text "admin_notes"
    t.string "processed_by"
    t.json "data_types_requested"
    t.datetime "estimated_completion_date"
    t.boolean "regulatory_hold", default: false
    t.text "hold_reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["processed_at"], name: "index_data_deletion_requests_on_processed_at"
    t.index ["requested_at"], name: "index_data_deletion_requests_on_requested_at"
    t.index ["status"], name: "index_data_deletion_requests_on_status"
    t.index ["user_id"], name: "index_data_deletion_requests_on_user_id"
  end

  create_table "investments", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "campaign_id", null: false
    t.decimal "amount"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["campaign_id"], name: "index_investments_on_campaign_id"
    t.index ["user_id"], name: "index_investments_on_user_id"
  end

  create_table "jwt_denylists", force: :cascade do |t|
    t.string "jti"
    t.datetime "exp"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["jti"], name: "index_jwt_denylists_on_jti"
  end

  create_table "kycs", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "docs_metadata"
    t.string "encrypted_id_number"
    t.string "encrypted_id_number_iv"
    t.string "encrypted_phone"
    t.string "encrypted_phone_iv"
    t.text "encrypted_address"
    t.string "encrypted_address_iv"
    t.text "encrypted_docs_metadata"
    t.string "encrypted_docs_metadata_iv"
    t.index ["encrypted_address_iv"], name: "index_kycs_on_encrypted_address_iv", unique: true
    t.index ["encrypted_docs_metadata_iv"], name: "index_kycs_on_encrypted_docs_metadata_iv", unique: true
    t.index ["encrypted_id_number_iv"], name: "index_kycs_on_encrypted_id_number_iv", unique: true
    t.index ["encrypted_phone_iv"], name: "index_kycs_on_encrypted_phone_iv", unique: true
    t.index ["user_id"], name: "index_kycs_on_user_id"
  end

  create_table "transaction_logs", force: :cascade do |t|
    t.bigint "user_id"
    t.string "action"
    t.string "record_type"
    t.bigint "record_id"
    t.json "details"
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_transaction_logs_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role", default: 3, null: false
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.datetime "consent_given_at"
    t.datetime "consent_withdrawn_at"
    t.string "consent_version"
    t.string "first_name"
    t.string "last_name"
    t.string "company_name"
    t.string "industry"
    t.string "business_stage"
    t.date "founded_date"
    t.string "website"
    t.text "business_description"
    t.text "problem_being_solved"
    t.text "target_market"
    t.text "competitive_advantage"
    t.decimal "funding_amount_needed", precision: 15, scale: 2
    t.text "funding_purpose"
    t.decimal "current_annual_revenue_min", precision: 15, scale: 2
    t.decimal "current_annual_revenue_max", precision: 15, scale: 2
    t.decimal "projected_annual_revenue_min", precision: 15, scale: 2
    t.decimal "projected_annual_revenue_max", precision: 15, scale: 2
    t.integer "team_size_min"
    t.integer "team_size_max"
    t.integer "number_of_co_founders"
    t.string "tin"
    t.string "legal_structure"
    t.string "phone_number"
    t.string "job_title"
    t.integer "years_of_experience_min"
    t.integer "years_of_experience_max"
    t.decimal "typical_investment_amount_min", precision: 15, scale: 2
    t.decimal "typical_investment_amount_max", precision: 15, scale: 2
    t.string "investment_frequency"
    t.text "preferred_industries", default: [], array: true
    t.text "preferred_investment_stages", default: [], array: true
    t.decimal "annual_income_min", precision: 15, scale: 2
    t.decimal "annual_income_max", precision: 15, scale: 2
    t.decimal "net_worth_min", precision: 15, scale: 2
    t.decimal "net_worth_max", precision: 15, scale: 2
    t.boolean "accredited_investor", default: false
    t.string "risk_tolerance"
    t.text "previous_investment_experience"
    t.text "investment_goals"
    t.decimal "minimum_investment", precision: 15, scale: 2
    t.decimal "maximum_investment", precision: 15, scale: 2
    t.boolean "terms_of_service_accepted", default: false
    t.boolean "privacy_policy_accepted", default: false
    t.datetime "terms_accepted_at"
    t.datetime "privacy_accepted_at"
    t.index ["accredited_investor"], name: "index_users_on_accredited_investor"
    t.index ["business_stage"], name: "index_users_on_business_stage"
    t.index ["company_name"], name: "index_users_on_company_name"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["industry"], name: "index_users_on_industry"
    t.index ["investment_frequency"], name: "index_users_on_investment_frequency"
    t.index ["job_title"], name: "index_users_on_job_title"
    t.index ["legal_structure"], name: "index_users_on_legal_structure"
    t.index ["phone_number"], name: "index_users_on_phone_number"
    t.index ["preferred_industries"], name: "index_users_on_preferred_industries", using: :gin
    t.index ["preferred_investment_stages"], name: "index_users_on_preferred_investment_stages", using: :gin
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["risk_tolerance"], name: "index_users_on_risk_tolerance"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "breaches", "users"
  add_foreign_key "campaigns", "users"
  add_foreign_key "data_deletion_requests", "users"
  add_foreign_key "investments", "campaigns"
  add_foreign_key "investments", "users"
  add_foreign_key "kycs", "users"
  add_foreign_key "transaction_logs", "users"
end
