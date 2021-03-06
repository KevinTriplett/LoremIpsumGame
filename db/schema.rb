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

ActiveRecord::Schema[7.0].define(version: 2022_08_02_030301) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "games", force: :cascade do |t|
    t.string "name"
    t.bigint "current_player_id"
    t.datetime "turn_start"
    t.datetime "turn_end"
    t.datetime "game_start"
    t.datetime "game_end"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "game_days"
    t.integer "turn_hours"
    t.string "token"
    t.index ["current_player_id"], name: "index_games_on_current_player_id"
    t.index ["token"], name: "index_games_on_token", unique: true
  end

  create_table "turns", force: :cascade do |t|
    t.text "entry"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_turns_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.bigint "game_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "token"
    t.index ["game_id"], name: "index_users_on_game_id"
    t.index ["token"], name: "index_users_on_token", unique: true
  end

end
