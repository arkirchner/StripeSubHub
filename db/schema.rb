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

ActiveRecord::Schema[8.0].define(version: 2024_10_06_084845) do
  create_table "stripe_events", primary_key: "stripe_id", id: :string, force: :cascade do |t|
    t.string "event_type", null: false
    t.json "data", null: false
    t.datetime "stripe_created_at", null: false
    t.datetime "created_at", null: false
    t.integer "status", default: 0, null: false
    t.string "processing_error", default: "", null: false
  end

  create_table "stripe_invoices", primary_key: "stripe_id", id: :string, force: :cascade do |t|
    t.integer "status", null: false
    t.datetime "last_stripe_event_created_at", null: false
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "stripe_subscriptions", primary_key: "stripe_id", id: :string, force: :cascade do |t|
    t.string "latest_invoice_id", default: "", null: false
    t.datetime "last_stripe_event_created_at", null: false
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", null: false
    t.index ["latest_invoice_id"], name: "index_stripe_subscriptions_on_latest_invoice_id"
  end
end
