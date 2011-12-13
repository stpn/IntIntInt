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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20111213203906) do

  create_table "comments", :force => true do |t|
    t.string   "content"
    t.integer  "video_id"
    t.string   "youtubeid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "connotations", :force => true do |t|
    t.string   "rating"
    t.string   "username"
    t.integer  "phrase_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "corpus_comments", :force => true do |t|
    t.string   "content"
    t.integer  "video_id"
    t.string   "youtubeid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "discards", :force => true do |t|
    t.string   "youtubeid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "discards", ["youtubeid"], :name => "index_discards_on_youtubeid"

  create_table "evaluations", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "keywords", :force => true do |t|
    t.string   "content"
    t.integer  "video_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "memberships", :force => true do |t|
    t.integer  "metaword_id"
    t.integer  "video_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "memberships", ["metaword_id"], :name => "index_memberships_on_metaword_id"
  add_index "memberships", ["video_id"], :name => "index_memberships_on_video_id"

  create_table "metawords", :force => true do |t|
    t.string   "content"
    t.string   "youtubeid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "rating"
  end

  create_table "phrases", :force => true do |t|
    t.string   "content"
    t.integer  "video_id"
    t.string   "youtubeid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "timecode"
    t.boolean  "rating"
  end

  add_index "phrases", ["video_id"], :name => "index_phrases_on_video_id"

  create_table "user_sessions", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "username"
    t.string   "email"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "persistence_token"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "videos", :force => true do |t|
    t.string   "name"
    t.string   "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "comments"
    t.string   "keywords"
    t.string   "views"
    t.boolean  "download"
    t.string   "rating"
  end

  add_index "videos", ["comments"], :name => "index_videos_on_comments"
  add_index "videos", ["content"], :name => "index_videos_on_content"
  add_index "videos", ["keywords"], :name => "index_videos_on_keywords"

  create_table "words", :force => true do |t|
    t.string   "content"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
