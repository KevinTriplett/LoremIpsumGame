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

ActiveRecord::Schema[7.0].define(version: 2022_09_06_022733) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "games", force: :cascade do |t|
    t.string "name"
    t.bigint "current_player_id"
    t.datetime "turn_start"
    t.datetime "turn_end"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "turn_hours"
    t.string "token"
    t.integer "num_rounds"
    t.integer "round"
    t.datetime "started"
    t.datetime "ended"
    t.integer "pause_rounds"
    t.boolean "paused"
    t.index ["current_player_id"], name: "index_games_on_current_player_id"
    t.index ["token"], name: "index_games_on_token", unique: true
  end

  create_table "turns", force: :cascade do |t|
    t.text "entry"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "round"
    t.bigint "game_id"
    t.integer "revision"
    t.index ["user_id"], name: "index_turns_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.bigint "game_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "token"
    t.boolean "reminded"
    t.integer "play_order"
    t.string "author_color"
    t.string "author_id"
    t.index ["game_id"], name: "index_users_on_game_id"
    t.index ["token"], name: "index_users_on_token", unique: true
  end

end
