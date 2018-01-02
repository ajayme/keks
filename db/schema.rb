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

ActiveRecord::Schema.define(version: 20171231111217) do

  create_table "answers", force: :cascade do |t|
    t.text "text"
    t.boolean "correct"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "question_id"
    t.integer "questions_count", default: 0, null: false
    t.index ["question_id"], name: "index_answers_on_question_id"
  end

  create_table "answers_categories", force: :cascade do |t|
    t.integer "answer_id"
    t.integer "category_id"
  end

  create_table "categories", force: :cascade do |t|
    t.text "text"
    t.boolean "correct"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.string "ident"
    t.boolean "is_root"
    t.boolean "released"
    t.integer "questions_count", default: 0, null: false
  end

  create_table "hints", force: :cascade do |t|
    t.integer "sort_hint"
    t.text "text"
    t.integer "question_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "perfs", force: :cascade do |t|
    t.text "agent"
    t.text "url"
    t.integer "load_time", limit: 8
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
  end

  create_table "questions", force: :cascade do |t|
    t.string "parent_type"
    t.integer "parent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "text"
    t.string "ident"
    t.integer "difficulty"
    t.integer "study_path"
    t.boolean "released"
    t.datetime "content_changed_at"
    t.integer "answers_count", default: 0, null: false
    t.string "video_link", limit: 255
    t.index ["parent_id"], name: "index_questions_on_parent_id"
    t.index ["parent_type", "parent_id"], name: "index_questions_on_parent_type_and_parent_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.integer "user_id"
    t.integer "question_id"
    t.text "comment"
    t.boolean "okay"
    t.string "votes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_reviews_on_question_id"
  end

  create_table "starred", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "question_id"
    t.index ["user_id", "question_id"], name: "index_starred_on_user_id_and_question_id"
  end

  create_table "stats", force: :cascade do |t|
    t.integer "user_id"
    t.integer "question_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "correct"
    t.boolean "skipped", default: false
    t.string "selected_answers", limit: 255
    t.integer "time_taken"
    t.index ["created_at"], name: "index_stats_on_created_at"
    t.index ["question_id", "skipped", "correct"], name: "index_stats_on_question_id_and_skipped_and_correct"
    t.index ["user_id"], name: "index_stats_on_user_id"
  end

  create_table "text_storage", force: :cascade do |t|
    t.string "ident"
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "nick"
    t.string "mail"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "remember_token"
    t.boolean "admin", default: false
    t.integer "study_path"
    t.text "enrollment_keys"
    t.string "password_reset_token"
    t.datetime "password_reset_sent_at"
    t.boolean "reviewer", default: false
    t.index ["remember_token"], name: "index_users_on_remember_token"
  end

end
