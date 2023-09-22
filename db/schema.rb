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

ActiveRecord::Schema[7.0].define(version: 2023_09_20_205547) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "attendances", force: :cascade do |t|
    t.bigint "turing_module_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "user_id"
    t.datetime "attendance_time", precision: nil
    t.string "meeting_type"
    t.bigint "meeting_id"
    t.index ["meeting_type", "meeting_id"], name: "index_attendances_on_meeting_type_and_meeting_id"
    t.index ["turing_module_id"], name: "index_attendances_on_turing_module_id"
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "innings", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "current", default: false
    t.date "start_date"
  end

  create_table "slack_presence_checks", force: :cascade do |t|
    t.datetime "check_time"
    t.bigint "student_id", null: false
    t.integer "presence"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["student_id"], name: "index_slack_presence_checks_on_student_id"
  end

  create_table "slack_threads", force: :cascade do |t|
    t.string "channel_id"
    t.string "sent_timestamp"
    t.datetime "start_time", precision: nil
  end

  create_table "student_attendances", force: :cascade do |t|
    t.integer "status"
    t.bigint "student_id"
    t.bigint "attendance_id"
    t.datetime "join_time", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "duration"
    t.index ["attendance_id"], name: "index_student_attendances_on_attendance_id"
    t.index ["student_id"], name: "index_student_attendances_on_student_id"
  end

  create_table "students", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "turing_module_id"
    t.string "slack_id"
    t.string "populi_id"
    t.index ["turing_module_id"], name: "index_students_on_turing_module_id"
  end

  create_table "turing_modules", force: :cascade do |t|
    t.bigint "inning_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
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
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "google_refresh_token"
    t.bigint "turing_module_id"
    t.string "organization_domain"
    t.integer "user_type", default: 0
    t.index ["turing_module_id"], name: "index_users_on_turing_module_id"
  end

  create_table "zoom_aliases", force: :cascade do |t|
    t.string "name"
    t.bigint "student_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "zoom_meeting_id"
    t.bigint "turing_module_id"
    t.index ["name", "turing_module_id"], name: "index_zoom_aliases_on_name_and_turing_module_id", unique: true
    t.index ["student_id"], name: "index_zoom_aliases_on_student_id"
    t.index ["turing_module_id"], name: "index_zoom_aliases_on_turing_module_id"
    t.index ["zoom_meeting_id"], name: "index_zoom_aliases_on_zoom_meeting_id"
  end

  create_table "zoom_meetings", force: :cascade do |t|
    t.string "meeting_id"
    t.string "title"
    t.datetime "start_time", precision: nil
    t.integer "duration"
    t.datetime "end_time"
  end

  add_foreign_key "attendances", "turing_modules"
  add_foreign_key "attendances", "users"
  add_foreign_key "slack_presence_checks", "students"
  add_foreign_key "student_attendances", "attendances"
  add_foreign_key "student_attendances", "students"
  add_foreign_key "students", "turing_modules"
  add_foreign_key "turing_modules", "innings"
  add_foreign_key "zoom_aliases", "turing_modules"
  add_foreign_key "zoom_aliases", "zoom_meetings"
end
