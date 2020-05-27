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

ActiveRecord::Schema.define(version: 2018_08_13_194626) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "houses", id: :serial, force: :cascade do |t|
    t.string "name"
  end

  create_table "houses_people", id: :serial, force: :cascade do |t|
    t.integer "person_id"
    t.integer "house_id"
    t.index ["house_id"], name: "index_houses_people_on_house_id"
    t.index ["person_id", "house_id"], name: "index_houses_people_on_person_id_and_house_id", unique: true
    t.index ["person_id"], name: "index_houses_people_on_person_id"
  end

  create_table "people", id: :serial, force: :cascade do |t|
    t.integer "father_id"
    t.integer "mother_id"
    t.string "name"
    t.string "role"
    t.boolean "bastard"
    t.index ["father_id"], name: "index_people_on_father_id"
    t.index ["mother_id"], name: "index_people_on_mother_id"
  end

  create_table "person_snapshots", id: :serial, force: :cascade do |t|
    t.integer "person_id", null: false
    t.jsonb "object", null: false
    t.jsonb "father_object"
    t.jsonb "mother_object"
    t.jsonb "houses_object", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["person_id"], name: "index_person_snapshots_on_person_id"
  end

  add_foreign_key "houses_people", "houses"
  add_foreign_key "houses_people", "people"
  add_foreign_key "people", "people", column: "father_id"
  add_foreign_key "people", "people", column: "mother_id"
  add_foreign_key "person_snapshots", "people"
end
