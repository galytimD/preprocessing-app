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

ActiveRecord::Schema[7.1].define(version: 2024_05_10_224055) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "datasets", force: :cascade do |t|
    t.string "name"
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "quality_status", default: 0
    t.string "owner"
    t.datetime "createTime"
    t.string "images_path", default: "", null: false
    t.index ["name"], name: "index_datasets_on_name", unique: true
  end

  create_table "images", force: :cascade do |t|
    t.string "name"
    t.bigint "dataset_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "path"
    t.string "coordinates"
    t.string "resolution"
    t.string "orientation"
    t.boolean "uploaded", default: false
    t.index ["dataset_id"], name: "index_images_on_dataset_id"
    t.index ["name", "dataset_id"], name: "index_images_on_name_and_dataset_id", unique: true
  end

  add_foreign_key "images", "datasets"
end
