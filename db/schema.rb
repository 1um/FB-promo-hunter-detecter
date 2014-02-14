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

ActiveRecord::Schema.define(version: 20140214073802) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "posts", force: true do |t|
    t.text    "text"
    t.float   "rate"
    t.boolean "manual_check"
    t.string  "pid"
    t.string  "link"
    t.integer "profile_id"
  end

  add_index "posts", ["id"], name: "index_posts_on_id", using: :btree
  add_index "posts", ["pid"], name: "index_posts_on_pid", using: :btree

  create_table "posts_profiles", force: true do |t|
    t.integer "post_id"
    t.integer "profile_id"
  end

  create_table "profiles", force: true do |t|
    t.string   "uid"
    t.string   "name"
    t.boolean  "ph_manual"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "ph_percent"
    t.boolean  "right"
  end

  add_index "profiles", ["uid"], name: "index_profiles_on_uid", unique: true, using: :btree

end
