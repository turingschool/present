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

ActiveRecord::Schema.define(version: 2021_12_10_222506) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "attendances", force: :cascade do |t|
    t.bigint "turing_module_id"
    t.string "zoom_meeting_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["turing_module_id"], name: "index_attendances_on_turing_module_id"
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "innings", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "turing_modules", force: :cascade do |t|
    t.bigint "inning_id"
    t.string "google_spreadsheet_id"
    t.string "google_sheet_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "program"
    t.integer "module_number"
    t.boolean "calendar_integration", default: false
    t.index ["inning_id"], name: "index_turing_modules_on_inning_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "google_id"
    t.string "email"
    t.string "google_oauth_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "google_refresh_token"
  end

  add_foreign_key "attendances", "turing_modules"
  add_foreign_key "attendances", "users"
  add_foreign_key "turing_modules", "innings"
end
