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

ActiveRecord::Schema.define(version: 20150203170855) do

  create_table "customers", force: true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "street_address"
    t.string   "city"
    t.string   "state"
    t.string   "postal_code"
    t.string   "customer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "merchant_accounts", force: true do |t|
    t.string   "status"
    t.string   "merchant_account_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "partners", force: true do |t|
    t.string   "partners_merchant_id"
    t.string   "merchant_public_id"
    t.string   "merchant_public_key"
    t.string   "merchant_private_key"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payment_methods", force: true do |t|
    t.string   "payment_token"
    t.string   "payment_instrument_type"
    t.string   "customer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subscriptions", force: true do |t|
    t.string  "subscription_id"
    t.string  "status"
    t.string  "plan_id"
    t.string  "payment_method_id"
    t.decimal "price"
    t.string  "addon"
    t.string  "discount"
    t.boolean "trial_period"
    t.integer "trial_duration"
  end

  create_table "transactions", force: true do |t|
    t.string   "transaction_id"
    t.string   "status"
    t.string   "amount"
    t.string   "transaction_type"
    t.string   "merchant_account_id"
    t.string   "payment_method_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
