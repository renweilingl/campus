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

ActiveRecord::Schema[8.1].define(version: 2026_11_20_061630) do
  create_table "categories", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name", null: false
    t.boolean "visible", default: true, null: false
    t.boolean "must_order", default: false, null: false
    t.integer "recommend", default: 0, null: false
    t.bigint "user_id", null: false
    t.bigint "shop_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["shop_id", "name"], name: "index_categories_on_shop_id_and_name", unique: true
    t.index ["shop_id"], name: "index_categories_on_shop_id"
    t.index ["user_id"], name: "index_categories_on_user_id"
  end

  create_table "good_specs", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name", null: false
    t.integer "price", default: 0, null: false
    t.integer "recommend", default: 0, null: false
    t.bigint "good_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["good_id", "name"], name: "index_good_specs_on_good_id_and_name", unique: true
    t.index ["good_id"], name: "index_good_specs_on_good_id"
  end

  create_table "goods", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name", null: false
    t.integer "price", default: 0, null: false
    t.integer "recommend", default: 0, null: false
    t.string "unit", null: false
    t.integer "stock", default: 0, null: false
    t.boolean "on_sale", default: true, null: false
    t.boolean "must_order", default: false, null: false
    t.string "image_url"
    t.bigint "user_id", null: false
    t.bigint "shop_id", null: false
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_goods_on_category_id"
    t.index ["shop_id", "name"], name: "index_goods_on_shop_id_and_name", unique: true
    t.index ["shop_id"], name: "index_goods_on_shop_id"
    t.index ["user_id"], name: "index_goods_on_user_id"
  end

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
    t.index ["user_id"], name: "index_shops_on_user_id", unique: true
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

  add_foreign_key "categories", "shops"
  add_foreign_key "categories", "users"
  add_foreign_key "good_specs", "goods"
  add_foreign_key "goods", "categories"
  add_foreign_key "goods", "shops"
  add_foreign_key "goods", "users"
  add_foreign_key "shops", "users"
end
