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

ActiveRecord::Schema.define(version: 20150316141835) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "approvals", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.datetime "date"
    t.boolean  "is_approved"
    t.string   "description"
    t.uuid     "user_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "approvals", ["user_id"], name: "index_approvals_on_user_id", using: :btree

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
    t.string   "file_id"
    t.uuid     "completion_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "certificates", ["completion_id"], name: "index_certificates_on_completion_id", using: :btree

  create_table "comments", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.datetime "date"
    t.text     "content"
    t.uuid     "user_id"
    t.uuid     "recommendation_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "comments", ["recommendation_id"], name: "index_comments_on_recommendation_id", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "completions", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.integer  "position_in_course"
    t.float    "points"
    t.string   "permissions",                     array: true
    t.datetime "date"
    t.uuid     "user_id"
    t.uuid     "course_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "completions", ["course_id"], name: "index_completions_on_course_id", using: :btree
  add_index "completions", ["user_id"], name: "index_completions_on_user_id", using: :btree

  create_table "course_assignments", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "name"
    t.datetime "deadline"
    t.float    "maximum_score"
    t.float    "average_score"
    t.uuid     "course_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "course_assignments", ["course_id"], name: "index_course_assignments_on_course_id", using: :btree

  create_table "course_requests", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.datetime "date"
    t.text     "description"
    t.uuid     "course_id"
    t.uuid     "user_id"
    t.uuid     "group_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "course_requests", ["course_id"], name: "index_course_requests_on_course_id", using: :btree
  add_index "course_requests", ["group_id"], name: "index_course_requests_on_group_id", using: :btree
  add_index "course_requests", ["user_id"], name: "index_course_requests_on_user_id", using: :btree

  create_table "course_results", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.float    "maximum_score"
    t.float    "average_score"
    t.float    "best_score"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "courses", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "name",                    null: false
    t.string   "url",                     null: false
    t.text     "abstract"
    t.string   "language"
    t.string   "imageId"
    t.string   "videoId"
    t.datetime "start_date",              null: false
    t.datetime "end_date",                null: false
    t.integer  "duration"
    t.float    "costs"
    t.string   "type_of_achievement"
    t.string   "difficulty"
    t.string   "provider_course_id",      null: false
    t.uuid     "mooc_provider_id",        null: false
    t.uuid     "course_result_id"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.float    "credit_points"
    t.float    "minimum_weekly_workload"
    t.float    "maximum_weekly_workload"
    t.string   "price_currency"
    t.string   "categories",                           array: true
    t.string   "requirements",                         array: true
    t.string   "course_instructors",                   array: true
    t.text     "description"
  end

  add_index "courses", ["course_result_id"], name: "index_courses_on_course_result_id", using: :btree
  add_index "courses", ["mooc_provider_id"], name: "index_courses_on_mooc_provider_id", using: :btree

  create_table "courses_users", id: false, force: :cascade do |t|
    t.uuid "course_id"
    t.uuid "user_id"
  end

  create_table "emails", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "address"
    t.boolean  "is_primary"
    t.uuid     "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "emails", ["user_id"], name: "index_emails_on_user_id", using: :btree

  create_table "evaluations", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "title"
    t.float    "rating"
    t.boolean  "is_verified"
    t.text     "description"
    t.datetime "date"
    t.uuid     "user_id"
    t.uuid     "course_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
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
    t.string   "imageId"
    t.text     "description"
    t.string   "primary_statistics",              array: true
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  create_table "mooc_providers", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "logo_id"
    t.string   "name"
    t.string   "url"
    t.text     "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "mooc_providers_users", id: false, force: :cascade do |t|
    t.uuid "mooc_provider_id"
    t.uuid "user_id"
  end

  create_table "news_emails", force: :cascade do |t|
    t.string   "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "progresses", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.float    "percentage"
    t.string   "permissions",              array: true
    t.uuid     "course_id"
    t.uuid     "user_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "progresses", ["course_id"], name: "index_progresses_on_course_id", using: :btree
  add_index "progresses", ["user_id"], name: "index_progresses_on_user_id", using: :btree

  create_table "recommendations", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.boolean  "is_obligatory"
    t.uuid     "user_id"
    t.uuid     "group_id"
    t.uuid     "course_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "recommendations", ["course_id"], name: "index_recommendations_on_course_id", using: :btree
  add_index "recommendations", ["group_id"], name: "index_recommendations_on_group_id", using: :btree
  add_index "recommendations", ["user_id"], name: "index_recommendations_on_user_id", using: :btree

  create_table "recommendations_users", id: false, force: :cascade do |t|
    t.uuid "recommendation_id"
    t.uuid "user_id"
  end

  create_table "statistics", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "name"
    t.text     "result"
    t.uuid     "group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "statistics", ["group_id"], name: "index_statistics_on_group_id", using: :btree

  create_table "user_assignments", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.datetime "date"
    t.float    "score"
    t.uuid     "user_id"
    t.uuid     "course_id"
    t.uuid     "course_assignment_id"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "user_assignments", ["course_assignment_id"], name: "index_user_assignments_on_course_assignment_id", using: :btree
  add_index "user_assignments", ["course_id"], name: "index_user_assignments_on_course_id", using: :btree
  add_index "user_assignments", ["user_id"], name: "index_user_assignments_on_user_id", using: :btree

  create_table "user_groups", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.boolean  "is_admin",   default: false
    t.uuid     "user_id"
    t.uuid     "group_id"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "user_groups", ["group_id"], name: "index_user_groups_on_group_id", using: :btree
  add_index "user_groups", ["user_id"], name: "index_user_groups_on_user_id", using: :btree

  create_table "users", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "gender"
    t.string   "profile_image_id"
    t.json     "email_settings"
    t.text     "about_me"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "approvals", "users"
  add_foreign_key "bookmarks", "courses"
  add_foreign_key "bookmarks", "users"
  add_foreign_key "certificates", "completions"
  add_foreign_key "comments", "recommendations"
  add_foreign_key "comments", "users"
  add_foreign_key "completions", "courses"
  add_foreign_key "completions", "users"
  add_foreign_key "course_assignments", "courses"
  add_foreign_key "course_requests", "courses"
  add_foreign_key "course_requests", "groups"
  add_foreign_key "course_requests", "users"
  add_foreign_key "courses", "course_results"
  add_foreign_key "courses", "mooc_providers"
  add_foreign_key "emails", "users"
  add_foreign_key "evaluations", "courses"
  add_foreign_key "evaluations", "users"
  add_foreign_key "group_invitations", "groups"
  add_foreign_key "progresses", "courses"
  add_foreign_key "progresses", "users"
  add_foreign_key "recommendations", "courses"
  add_foreign_key "recommendations", "groups"
  add_foreign_key "recommendations", "users"
  add_foreign_key "statistics", "groups"
  add_foreign_key "user_assignments", "course_assignments"
  add_foreign_key "user_assignments", "courses"
  add_foreign_key "user_assignments", "users"
  add_foreign_key "user_groups", "groups"
  add_foreign_key "user_groups", "users"
end
