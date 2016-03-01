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

ActiveRecord::Schema.define(version: 20160229083711) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "activities", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "trackable_id"
    t.string   "trackable_type"
    t.uuid     "owner_id"
    t.string   "owner_type"
    t.string   "key"
    t.text     "parameters"
    t.uuid     "recipient_id"
    t.string   "recipient_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.uuid     "user_ids",       array: true
    t.uuid     "group_ids",      array: true
  end

  add_index "activities", ["owner_id", "owner_type"], name: "index_activities_on_owner_id_and_owner_type", using: :btree
  add_index "activities", ["recipient_id", "recipient_type"], name: "index_activities_on_recipient_id_and_recipient_type", using: :btree
  add_index "activities", ["trackable_id", "trackable_type"], name: "index_activities_on_trackable_id_and_trackable_type", using: :btree

  create_table "bookmarks", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "user_id"
    t.uuid     "course_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "bookmarks", ["course_id"], name: "index_bookmarks_on_course_id", using: :btree
  add_index "bookmarks", ["user_id"], name: "index_bookmarks_on_user_id", using: :btree

  create_table "certificates", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "title"
    t.uuid     "completion_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.string   "download_url",     null: false
    t.string   "verification_url"
    t.string   "document_type"
  end

  add_index "certificates", ["completion_id"], name: "index_certificates_on_completion_id", using: :btree

  create_table "completions", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.float    "quantile"
    t.float    "points_achieved"
    t.uuid     "user_id"
    t.uuid     "course_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.float    "provider_percentage"
  end

  add_index "completions", ["course_id"], name: "index_completions_on_course_id", using: :btree
  add_index "completions", ["user_id"], name: "index_completions_on_user_id", using: :btree

  create_table "course_track_types", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string "type_of_achievement", null: false
    t.string "title",               null: false
    t.text   "description"
  end

  create_table "course_tracks", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.float  "costs"
    t.string "costs_currency"
    t.uuid   "course_track_type_id"
    t.uuid   "course_id"
    t.float  "credit_points"
  end

  add_index "course_tracks", ["course_id"], name: "index_course_tracks_on_course_id", using: :btree
  add_index "course_tracks", ["course_track_type_id"], name: "index_course_tracks_on_course_track_type_id", using: :btree

  create_table "courses", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "name",                        null: false
    t.string   "url",                         null: false
    t.text     "abstract"
    t.string   "language"
    t.string   "videoId"
    t.datetime "start_date"
    t.datetime "end_date"
    t.string   "difficulty"
    t.string   "provider_course_id",          null: false
    t.uuid     "mooc_provider_id",            null: false
    t.uuid     "course_result_id"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "categories",                               array: true
    t.string   "requirements",                             array: true
    t.string   "course_instructors"
    t.text     "description"
    t.boolean  "open_for_registration"
    t.string   "workload"
    t.string   "subtitle_languages"
    t.integer  "calculated_duration_in_days"
    t.string   "provider_given_duration"
    t.float    "calculated_rating"
    t.integer  "rating_count"
    t.float    "points_maximal"
    t.string   "course_image_file_name"
    t.string   "course_image_content_type"
    t.integer  "course_image_file_size"
    t.datetime "course_image_updated_at"
    t.uuid     "previous_iteration_id"
    t.uuid     "following_iteration_id"
    t.string   "organisation"
  end

  add_index "courses", ["course_result_id"], name: "index_courses_on_course_result_id", using: :btree
  add_index "courses", ["following_iteration_id"], name: "index_courses_on_following_iteration_id", using: :btree
  add_index "courses", ["mooc_provider_id"], name: "index_courses_on_mooc_provider_id", using: :btree
  add_index "courses", ["previous_iteration_id"], name: "index_courses_on_previous_iteration_id", using: :btree

  create_table "courses_users", id: false, force: :cascade do |t|
    t.uuid "course_id"
    t.uuid "user_id"
  end

  create_table "evaluations", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.float    "rating"
    t.boolean  "is_verified"
    t.text     "description"
    t.uuid     "user_id"
    t.uuid     "course_id"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "course_status"
    t.boolean  "rated_anonymously"
    t.integer  "total_feedback_count",    default: 0, null: false
    t.integer  "positive_feedback_count", default: 0, null: false
  end

  add_index "evaluations", ["course_id"], name: "index_evaluations_on_course_id", using: :btree
  add_index "evaluations", ["user_id"], name: "index_evaluations_on_user_id", using: :btree

  create_table "group_invitations", force: :cascade do |t|
    t.uuid     "group_id"
    t.string   "token",                       null: false
    t.datetime "expiry_date",                 null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.boolean  "used",        default: false
  end

  add_index "group_invitations", ["group_id"], name: "index_group_invitations_on_group_id", using: :btree

  create_table "groups", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.string   "primary_statistics",              array: true
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
  end

  create_table "mooc_provider_users", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "user_id"
    t.uuid     "mooc_provider_id"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.string   "refresh_token"
    t.string   "access_token"
    t.datetime "access_token_valid_until"
  end

  add_index "mooc_provider_users", ["mooc_provider_id"], name: "index_mooc_provider_users_on_mooc_provider_id", using: :btree
  add_index "mooc_provider_users", ["user_id", "mooc_provider_id"], name: "index_mooc_provider_users_on_user_id_and_mooc_provider_id", unique: true, using: :btree
  add_index "mooc_provider_users", ["user_id"], name: "index_mooc_provider_users_on_user_id", using: :btree

  create_table "mooc_providers", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "logo_id"
    t.string   "name",              null: false
    t.string   "url"
    t.text     "description"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.integer  "api_support_state"
  end

  add_index "mooc_providers", ["name"], name: "index_mooc_providers_on_name", unique: true, using: :btree

  create_table "recommendations", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.boolean  "is_obligatory"
    t.uuid     "course_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.text     "text"
    t.uuid     "author_id"
    t.uuid     "group_id"
  end

  add_index "recommendations", ["author_id"], name: "index_recommendations_on_author_id", using: :btree
  add_index "recommendations", ["course_id"], name: "index_recommendations_on_course_id", using: :btree
  add_index "recommendations", ["group_id"], name: "index_recommendations_on_group_id", using: :btree

  create_table "recommendations_users", id: false, force: :cascade do |t|
    t.uuid "recommendation_id"
    t.uuid "user_id"
  end

  create_table "user_emails", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "address"
    t.boolean  "is_primary"
    t.uuid     "user_id"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.boolean  "is_verified", default: false, null: false
  end

  add_index "user_emails", ["user_id"], name: "index_user_emails_on_user_id", using: :btree

  create_table "user_groups", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.boolean  "is_admin",   default: false
    t.uuid     "user_id"
    t.uuid     "group_id"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "user_groups", ["group_id"], name: "index_user_groups_on_group_id", using: :btree
  add_index "user_groups", ["user_id"], name: "index_user_groups_on_user_id", using: :btree

  create_table "user_identities", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "user_id"
    t.string   "omniauth_provider"
    t.string   "provider_user_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "user_identities", ["user_id"], name: "index_user_identities_on_user_id", using: :btree

  create_table "user_setting_entries", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "key"
    t.string   "value"
    t.uuid     "user_setting_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "user_setting_entries", ["user_setting_id"], name: "index_user_setting_entries_on_user_setting_id", using: :btree

  create_table "user_settings", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "name"
    t.uuid     "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "user_settings", ["user_id"], name: "index_user_settings_on_user_id", using: :btree

  create_table "users", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "gender"
    t.json     "email_settings"
    t.text     "about_me"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.string   "encrypted_password",         default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",              default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.boolean  "password_autogenerated",     default: false, null: false
    t.string   "profile_image_file_name"
    t.string   "profile_image_content_type"
    t.integer  "profile_image_file_size"
    t.datetime "profile_image_updated_at"
  end

  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "bookmarks", "courses"
  add_foreign_key "bookmarks", "users"
  add_foreign_key "certificates", "completions"
  add_foreign_key "completions", "courses"
  add_foreign_key "completions", "users"
  add_foreign_key "course_tracks", "course_track_types"
  add_foreign_key "course_tracks", "courses"
  add_foreign_key "courses", "courses", column: "following_iteration_id"
  add_foreign_key "courses", "courses", column: "previous_iteration_id"
  add_foreign_key "courses", "mooc_providers"
  add_foreign_key "evaluations", "courses"
  add_foreign_key "evaluations", "users"
  add_foreign_key "group_invitations", "groups"
  add_foreign_key "mooc_provider_users", "mooc_providers"
  add_foreign_key "mooc_provider_users", "users"
  add_foreign_key "recommendations", "courses"
  add_foreign_key "recommendations", "groups"
  add_foreign_key "recommendations", "users", column: "author_id"
  add_foreign_key "user_emails", "users"
  add_foreign_key "user_groups", "groups"
  add_foreign_key "user_groups", "users"
  add_foreign_key "user_identities", "users"
  add_foreign_key "user_setting_entries", "user_settings"
  add_foreign_key "user_settings", "users"
end
