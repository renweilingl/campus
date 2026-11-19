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

ActiveRecord::Schema[8.1].define(version: 2026_11_18_062439) do
  create_table "shops", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "contact_phone", null: false
    t.integer "delivery_fee", default: 0, null: false
    t.integer "delivery_time", default: 0, null: false
    t.string "description"
    t.integer "mini_fee", default: 0, null: false
    t.integer "packaging_fee", default: 0, null: false
    t.boolean "status", default: true, null: false
    t.string "store_code", null: false
    t.string "mch_id"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["store_code"], name: "index_shops_on_store_code", unique: true
    t.index ["user_id"], name: "index_shops_on_user_id"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "phone", null: false
    t.string "crypted_password"
    t.string "salt"
    t.string "nickname"
    t.string "role", default: "user", null: false
    t.string "status", default: "enabled", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["phone"], name: "index_users_on_phone", unique: true
  end

  add_foreign_key "shops", "users"
end
