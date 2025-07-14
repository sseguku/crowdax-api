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

ActiveRecord::Schema[8.0].define(version: 2025_07_14_225918) do
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
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
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
