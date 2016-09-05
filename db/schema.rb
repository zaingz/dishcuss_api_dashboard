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

ActiveRecord::Schema.define(version: 20160826075236) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "call_nows", force: :cascade do |t|
    t.string   "number"
    t.integer  "restaurant_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "categories", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "categories_food_items", id: false, force: :cascade do |t|
    t.integer "category_id"
    t.integer "food_item_id"
  end

  add_index "categories_food_items", ["category_id", "food_item_id"], name: "index_categories_food_items_on_category_id_and_food_item_id", using: :btree

  create_table "checkins", force: :cascade do |t|
    t.string   "address"
    t.integer  "post_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.float    "lat"
    t.float    "long"
    t.integer  "restaurant_id"
  end

  create_table "comments", force: :cascade do |t|
    t.string   "title",            limit: 50, default: ""
    t.text     "comment"
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.integer  "user_id"
    t.string   "role",                        default: "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["commentable_id"], name: "index_comments_on_commentable_id", using: :btree
  add_index "comments", ["commentable_type"], name: "index_comments_on_commentable_type", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "cover_images", force: :cascade do |t|
    t.string   "image"
    t.integer  "restaurant_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "credit_adjustments", force: :cascade do |t|
    t.string   "typee",      default: ""
    t.integer  "points",     default: 0
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "credit_histories", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "restaurant_id"
    t.integer  "price"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "qrcode_id"
  end

  create_table "credits", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "points",     default: 0
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "dislikes", force: :cascade do |t|
    t.integer  "dislikeable_id"
    t.string   "dislikeable_type"
    t.integer  "disliker_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "follows", force: :cascade do |t|
    t.string   "follower_type"
    t.integer  "follower_id"
    t.string   "followable_type"
    t.integer  "followable_id"
    t.datetime "created_at"
  end

  add_index "follows", ["followable_id", "followable_type"], name: "fk_followables", using: :btree
  add_index "follows", ["follower_id", "follower_type"], name: "fk_follows", using: :btree

  create_table "food_items", force: :cascade do |t|
    t.string   "name"
    t.float    "price"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.integer  "likers_count", default: 0
    t.integer  "section_id"
  end

  create_table "identities", force: :cascade do |t|
    t.string   "provider",   default: ""
    t.string   "uid",        default: ""
    t.string   "url",        default: ""
    t.string   "token",      default: ""
    t.datetime "expires_at"
    t.integer  "user_id"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "likes", force: :cascade do |t|
    t.string   "liker_type"
    t.integer  "liker_id"
    t.string   "likeable_type"
    t.integer  "likeable_id"
    t.datetime "created_at"
  end

  add_index "likes", ["likeable_id", "likeable_type"], name: "fk_likeables", using: :btree
  add_index "likes", ["liker_id", "liker_type"], name: "fk_likes", using: :btree

  create_table "menus", force: :cascade do |t|
    t.string   "name"
    t.text     "summary"
    t.integer  "restaurant_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "messages", force: :cascade do |t|
    t.text     "body"
    t.integer  "status",        default: 0
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "sender_id"
    t.string   "sender_type"
    t.integer  "reciever_id"
    t.string   "reciever_type"
  end

  create_table "models", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "models", ["email"], name: "index_models_on_email", unique: true, using: :btree
  add_index "models", ["reset_password_token"], name: "index_models_on_reset_password_token", unique: true, using: :btree

  create_table "newsfeeds", force: :cascade do |t|
    t.integer  "ids",        default: [],              array: true
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "feed_id"
    t.string   "feed_type"
  end

  create_table "notifications", force: :cascade do |t|
    t.integer  "notifier_id"
    t.string   "notifier_type"
    t.integer  "target_id"
    t.string   "target_type"
    t.text     "body"
    t.boolean  "seen",          default: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  create_table "offer_images", force: :cascade do |t|
    t.string   "image"
    t.integer  "qrcode_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "photos", force: :cascade do |t|
    t.integer  "imageable_id"
    t.string   "imageable_type"
    t.string   "image"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "posts", force: :cascade do |t|
    t.string   "title"
    t.text     "status"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.integer  "user_id"
    t.integer  "likers_count", default: 0
  end

  create_table "qrcodes", force: :cascade do |t|
    t.string   "code"
    t.integer  "restaurant_id"
    t.integer  "points"
    t.string   "description",   default: ""
    t.string   "img"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "ratings", force: :cascade do |t|
    t.integer  "rate",          default: 0
    t.integer  "restaurant_id"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "user_id"
  end

  create_table "referrals", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "referred_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "reports", force: :cascade do |t|
    t.text     "reason"
    t.integer  "user_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "reportable_id"
    t.string   "reportable_type"
  end

  create_table "restaurants", force: :cascade do |t|
    t.string   "name"
    t.datetime "opening_time"
    t.datetime "closing_time"
    t.string   "location"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.boolean  "approved",        default: false
    t.integer  "owner_id"
    t.integer  "followers_count", default: 0
    t.integer  "likers_count",    default: 0
    t.boolean  "featured",        default: false
    t.boolean  "claim_credit",    default: false
    t.float    "latitude"
    t.float    "longitude"
  end

  create_table "reviews", force: :cascade do |t|
    t.string   "title"
    t.text     "summary"
    t.integer  "rating"
    t.integer  "reviewable_id"
    t.string   "reviewable_type"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "reviewer_id"
    t.integer  "likers_count",    default: 0
  end

  create_table "sections", force: :cascade do |t|
    t.string   "title"
    t.integer  "menu_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "name",                   default: ""
    t.string   "username",               default: ""
    t.string   "email",                  default: ""
    t.string   "avatar",                 default: ""
    t.string   "location",               default: ""
    t.integer  "gender"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "password"
    t.integer  "role",                   default: 0
    t.integer  "followees_count",        default: 0
    t.integer  "followers_count",        default: 0
    t.integer  "likees_count",           default: 0
    t.boolean  "verified",               default: false
    t.datetime "dob"
    t.string   "referal_code",           default: ""
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.boolean  "block",                  default: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end