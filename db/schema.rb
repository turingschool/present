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

ActiveRecord::Schema.define(version: 2023_03_30_145308) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "attendances", force: :cascade do |t|
    t.bigint "turing_module_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.datetime "attendance_time"
    t.string "meeting_type"
    t.bigint "meeting_id"
    t.index ["meeting_type", "meeting_id"], name: "index_attendances_on_meeting_type_and_meeting_id"
    t.index ["turing_module_id"], name: "index_attendances_on_turing_module_id"
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "innings", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "current", default: false
  end

  create_table "slack_threads", force: :cascade do |t|
    t.string "channel_id"
    t.datetime "sent_timestamp"
    t.datetime "start_time"
  end

  create_table "student_attendances", force: :cascade do |t|
    t.integer "status"
    t.bigint "student_id"
    t.bigint "attendance_id"
    t.datetime "join_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["attendance_id"], name: "index_student_attendances_on_attendance_id"
    t.index ["student_id"], name: "index_student_attendances_on_student_id"
  end

  create_table "students", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "turing_module_id"
    t.string "slack_id"
    t.string "populi_id"
    t.index ["turing_module_id"], name: "index_students_on_turing_module_id"
  end

  create_table "turing_modules", force: :cascade do |t|
    t.bigint "inning_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "program"
    t.integer "module_number"
    t.boolean "calendar_integration", default: false
    t.string "slack_channel_id"
    t.string "populi_course_id"
    t.index ["inning_id"], name: "index_turing_modules_on_inning_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "google_id"
    t.string "email"
    t.string "google_oauth_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "google_refresh_token"
    t.bigint "turing_module_id"
    t.string "organization_domain"
    t.index ["turing_module_id"], name: "index_users_on_turing_module_id"
  end

  create_table "zoom_aliases", force: :cascade do |t|
    t.string "name"
    t.bigint "student_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "zoom_meeting_id"
    t.index ["student_id"], name: "index_zoom_aliases_on_student_id"
    t.index ["zoom_meeting_id"], name: "index_zoom_aliases_on_zoom_meeting_id"
  end

  create_table "zoom_meetings", force: :cascade do |t|
    t.string "meeting_id"
    t.string "title"
    t.datetime "start_time"
  end

  add_foreign_key "attendances", "turing_modules"
  add_foreign_key "attendances", "users"
  add_foreign_key "student_attendances", "attendances"
  add_foreign_key "student_attendances", "students"
  add_foreign_key "students", "turing_modules"
  add_foreign_key "turing_modules", "innings"
  add_foreign_key "zoom_aliases", "zoom_meetings"
end
