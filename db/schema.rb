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

ActiveRecord::Schema[7.0].define(version: 2022_12_23_101224) do
  create_table "broadcasts", force: :cascade do |t|
    t.text "content", null: false
    t.string "title", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_broadcasts_on_user_id"
  end

  create_table "comments", force: :cascade do |t|
    t.integer "post_id"
    t.integer "user_id"
    t.text "content", limit: 16777216, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "likes", default: 0
    t.integer "hates", default: 0
    t.index ["post_id"], name: "index_comments_on_post_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "commodities", force: :cascade do |t|
    t.string "name", null: false
    t.integer "price"
    t.text "description", limit: 16777216
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "commodity_group_id"
    t.index ["commodity_group_id"], name: "index_commodities_on_commodity_group_id"
  end

  create_table "commodity_groups", force: :cascade do |t|
    t.integer "post_id"
    t.integer "number", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["post_id"], name: "index_commodity_groups_on_post_id"
  end

  create_table "complaints", force: :cascade do |t|
    t.text "content", limit: 16777216, null: false
    t.integer "user_id"
    t.integer "post_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status"
    t.index ["post_id"], name: "index_complaints_on_post_id"
    t.index ["user_id"], name: "index_complaints_on_user_id"
  end

  create_table "follow_infos", force: :cascade do |t|
    t.integer "user_id"
    t.integer "post_id"
    t.text "annotation", limit: 16777216, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["post_id"], name: "index_follow_infos_on_post_id"
    t.index ["user_id"], name: "index_follow_infos_on_user_id"
  end

  create_table "images", force: :cascade do |t|
    t.integer "category", null: false
    t.integer "user_id"
    t.integer "commodity_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["commodity_id"], name: "index_images_on_commodity_id"
    t.index ["user_id"], name: "index_images_on_user_id"
  end

  create_table "indents", force: :cascade do |t|
    t.integer "num", null: false
    t.integer "status", null: false
    t.integer "commodity_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["commodity_id"], name: "index_indents_on_commodity_id"
    t.index ["user_id"], name: "index_indents_on_user_id"
  end

  create_table "inner_comments", force: :cascade do |t|
    t.integer "user_id"
    t.integer "comment_id"
    t.text "content", limit: 16777216, null: false
    t.integer "reply_object_type", null: false
    t.bigint "reply_comment_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "likes", default: 0
    t.integer "hates", default: 0
    t.index ["comment_id"], name: "index_inner_comments_on_comment_id"
    t.index ["user_id"], name: "index_inner_comments_on_user_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.integer "status", null: false
    t.integer "direction", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.integer "deliver_id"
    t.text "content"
    t.integer "indent_id"
    t.index ["indent_id"], name: "index_notifications_on_indent_id"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "posts", force: :cascade do |t|
    t.string "title", null: false
    t.text "content", limit: 16777216, null: false
    t.integer "category", null: false
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "heat"
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "posts_tags", force: :cascade do |t|
    t.integer "tag_id"
    t.integer "post_id"
    t.index ["post_id"], name: "index_posts_tags_on_post_id"
    t.index ["tag_id"], name: "index_posts_tags_on_tag_id"
  end

  create_table "replies", force: :cascade do |t|
    t.text "content", null: false
    t.integer "status", null: false
    t.integer "user_id"
    t.integer "post_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "deliver_id"
    t.index ["post_id"], name: "index_replies_on_post_id"
    t.index ["user_id"], name: "index_replies_on_user_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "tag_name", null: false
    t.integer "reference_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "trolleys", force: :cascade do |t|
    t.integer "number", null: false
    t.integer "user_id"
    t.integer "commodity_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["commodity_id"], name: "index_trolleys_on_commodity_id"
    t.index ["user_id"], name: "index_trolleys_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.string "email"
    t.string "password"
    t.string "student_id"
    t.integer "failures_on_login"
    t.datetime "last_failure_on_login"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_role", default: 1, null: false
    t.integer "uploaded"
  end

  add_foreign_key "broadcasts", "users"
  add_foreign_key "comments", "posts"
  add_foreign_key "comments", "users"
  add_foreign_key "commodities", "commodity_groups"
  add_foreign_key "commodity_groups", "posts"
  add_foreign_key "complaints", "posts"
  add_foreign_key "complaints", "users"
  add_foreign_key "images", "commodities"
  add_foreign_key "images", "users"
  add_foreign_key "indents", "commodities"
  add_foreign_key "indents", "users"
  add_foreign_key "inner_comments", "comments"
  add_foreign_key "inner_comments", "users"
  add_foreign_key "notifications", "indents"
  add_foreign_key "notifications", "users"
  add_foreign_key "posts", "users"
  add_foreign_key "replies", "posts"
  add_foreign_key "replies", "users"
  add_foreign_key "trolleys", "commodities"
  add_foreign_key "trolleys", "users"
end
