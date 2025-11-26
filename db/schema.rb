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

ActiveRecord::Schema[8.1].define(version: 2025_11_26_202441) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "customers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "name", null: false
    t.string "phone", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_customers_on_email", unique: true
  end

  create_table "reservations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "customer_id", null: false
    t.datetime "end_time", null: false
    t.datetime "start_time", null: false
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.bigint "vehicle_id", null: false
    t.index ["customer_id"], name: "index_reservations_on_customer_id"
    t.index ["status"], name: "index_reservations_on_status"
    t.index ["vehicle_id", "start_time", "end_time"], name: "index_reservations_on_vehicle_id_and_start_time_and_end_time"
    t.index ["vehicle_id"], name: "index_reservations_on_vehicle_id"
  end

  create_table "vehicles", force: :cascade do |t|
    t.string "color", null: false
    t.datetime "created_at", null: false
    t.bigint "customer_id", null: false
    t.string "license_plate", null: false
    t.string "make", null: false
    t.string "model", null: false
    t.datetime "updated_at", null: false
    t.integer "year", null: false
    t.index ["customer_id"], name: "index_vehicles_on_customer_id"
    t.index ["license_plate"], name: "index_vehicles_on_license_plate", unique: true
  end

  add_foreign_key "reservations", "customers"
  add_foreign_key "reservations", "vehicles"
  add_foreign_key "vehicles", "customers"
end
