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

ActiveRecord::Schema[8.0].define(version: 2026_05_03_170734) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "ahoy_events", force: :cascade do |t|
    t.bigint "visit_id"
    t.bigint "user_id"
    t.string "name"
    t.jsonb "properties"
    t.datetime "time"
    t.index ["name", "time"], name: "index_ahoy_events_on_name_and_time"
    t.index ["properties"], name: "index_ahoy_events_on_properties", opclass: :jsonb_path_ops, using: :gin
    t.index ["user_id"], name: "index_ahoy_events_on_user_id"
    t.index ["visit_id"], name: "index_ahoy_events_on_visit_id"
  end

  create_table "ahoy_visits", force: :cascade do |t|
    t.string "visit_token"
    t.string "visitor_token"
    t.bigint "user_id"
    t.string "ip"
    t.text "user_agent"
    t.text "referrer"
    t.string "referring_domain"
    t.text "landing_page"
    t.string "browser"
    t.string "os"
    t.string "device_type"
    t.string "country"
    t.string "region"
    t.string "city"
    t.float "latitude"
    t.float "longitude"
    t.string "utm_source"
    t.string "utm_medium"
    t.string "utm_term"
    t.string "utm_content"
    t.string "utm_campaign"
    t.string "app_version"
    t.string "os_version"
    t.string "platform"
    t.datetime "started_at"
    t.index ["user_id"], name: "index_ahoy_visits_on_user_id"
    t.index ["visit_token"], name: "index_ahoy_visits_on_visit_token", unique: true
    t.index ["visitor_token", "started_at"], name: "index_ahoy_visits_on_visitor_token_and_started_at"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "individual_projects", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_individual_projects_on_user_id"
  end

  create_table "individual_tasks", force: :cascade do |t|
    t.bigint "individual_project_id", null: false
    t.string "name"
    t.string "description"
    t.datetime "due_date", null: false
    t.datetime "reminder_date"
    t.string "difficulty"
    t.boolean "read"
    t.integer "points"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "status_complete", default: false, null: false
    t.index ["individual_project_id"], name: "index_individual_tasks_on_individual_project_id"
  end

  create_table "interests", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "items", force: :cascade do |t|
    t.string "name"
    t.integer "price"
    t.string "description"
    t.string "image_url"
    t.string "category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "shared_invite_id"
    t.bigint "team_project_task_id"
    t.bigint "individual_task_id"
    t.string "message", null: false
    t.boolean "read", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["individual_task_id"], name: "index_notifications_on_individual_task_id"
    t.index ["shared_invite_id"], name: "index_notifications_on_shared_invite_id"
    t.index ["team_project_task_id"], name: "index_notifications_on_team_project_task_id"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "plants", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "last_watered_at"
    t.bigint "plant_type_id", null: false
    t.bigint "pot_type_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "plant_image"
    t.index ["plant_type_id"], name: "index_plants_on_plant_type_id"
    t.index ["pot_type_id"], name: "index_plants_on_pot_type_id"
    t.index ["user_id"], name: "index_plants_on_user_id"
  end

  create_table "posts", force: :cascade do |t|
    t.bigint "parent_id"
    t.boolean "answer_by_admin", default: false
    t.boolean "hidden", default: false
    t.integer "interest_count", default: 0
    t.string "title"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_id"], name: "index_posts_on_parent_id"
  end

  create_table "radar_categories", force: :cascade do |t|
    t.bigint "team_project_id", null: false
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["team_project_id"], name: "index_radar_categories_on_team_project_id"
  end

  create_table "radar_ratings", force: :cascade do |t|
    t.bigint "radar_category_id", null: false
    t.bigint "team_project_id", null: false
    t.integer "category_rating"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "team_project_member_id"
    t.index ["radar_category_id"], name: "index_radar_ratings_on_radar_category_id"
    t.index ["team_project_id"], name: "index_radar_ratings_on_team_project_id"
    t.index ["team_project_member_id"], name: "index_radar_ratings_on_team_project_member_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.integer "rating"
    t.text "body"
    t.integer "positive_interest_count", default: 0
    t.integer "negative_interest_count", default: 0
    t.boolean "hidden", default: false
    t.integer "review_index"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
  end

  create_table "sessions", force: :cascade do |t|
    t.string "session_id", null: false
    t.text "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "shared_invites", force: :cascade do |t|
    t.string "email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "team_project_id", null: false
    t.index ["team_project_id"], name: "index_shared_invites_on_team_project_id"
  end

  create_table "team_project_members", force: :cascade do |t|
    t.bigint "team_project_id", null: false
    t.bigint "user_id", null: false
    t.string "role", default: "team_member"
    t.datetime "joined_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.boolean "leaderboard_visibility", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "points", default: 0, null: false
    t.index ["team_project_id"], name: "index_team_project_members_on_team_project_id"
    t.index ["user_id"], name: "index_team_project_members_on_user_id"
  end

  create_table "team_project_tasks", force: :cascade do |t|
    t.bigint "team_project_id", null: false
    t.string "name"
    t.string "description"
    t.datetime "due_date", null: false
    t.datetime "reminder_date"
    t.string "difficulty"
    t.integer "points"
    t.boolean "read"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "status_complete", default: false, null: false
    t.index ["team_project_id"], name: "index_team_project_tasks_on_team_project_id"
  end

  create_table "team_projects", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.boolean "leaderboard_visible", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image_path"
  end

  create_table "team_task_assignments", force: :cascade do |t|
    t.bigint "team_project_task_id", null: false
    t.bigint "team_project_member_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["team_project_member_id"], name: "index_team_task_assignments_on_team_project_member_id"
    t.index ["team_project_task_id", "team_project_member_id"], name: "index_team_task_assignments_on_task_and_member", unique: true
    t.index ["team_project_task_id"], name: "index_team_task_assignments_on_team_project_task_id"
  end

  create_table "user_items", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "item_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "purchased_at"
    t.index ["item_id"], name: "index_user_items_on_item_id"
    t.index ["user_id"], name: "index_user_items_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name", default: ""
    t.string "last_name", default: ""
    t.string "role", default: "subscriber"
    t.string "registration_ip"
    t.string "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer "invitation_limit"
    t.integer "invited_by_id"
    t.string "invited_by_type"
    t.integer "points", default: 0, null: false
    t.integer "layout"
    t.boolean "was_subscriber", default: true, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "individual_projects", "users"
  add_foreign_key "individual_tasks", "individual_projects"
  add_foreign_key "notifications", "individual_tasks"
  add_foreign_key "notifications", "shared_invites"
  add_foreign_key "notifications", "team_project_tasks"
  add_foreign_key "notifications", "users"
  add_foreign_key "plants", "items", column: "plant_type_id"
  add_foreign_key "plants", "items", column: "pot_type_id"
  add_foreign_key "plants", "users"
  add_foreign_key "posts", "posts", column: "parent_id"
  add_foreign_key "radar_categories", "team_projects"
  add_foreign_key "radar_ratings", "radar_categories"
  add_foreign_key "radar_ratings", "team_project_members"
  add_foreign_key "radar_ratings", "team_projects"
  add_foreign_key "shared_invites", "team_projects"
  add_foreign_key "team_project_members", "team_projects"
  add_foreign_key "team_project_members", "users"
  add_foreign_key "team_project_tasks", "team_projects"
  add_foreign_key "team_task_assignments", "team_project_members"
  add_foreign_key "team_task_assignments", "team_project_tasks"
  add_foreign_key "user_items", "items"
  add_foreign_key "user_items", "users"
end
