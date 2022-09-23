require "test_helper"

class AdminGameTest < ActionDispatch::IntegrationTest
  DatabaseCleaner.clean

  test "Admin page with no games" do
    DatabaseCleaner.cleaning do
      get admin_games_path
  
      assert_select "h1", "Lorem Ipsum Admin"
      assert_select "h5", "No Existing Games"
    end
  end

  test "Admin page with games and no users" do
    DatabaseCleaner.cleaning do
      game = create_game

      get admin_games_path
      assert_select "h5", "Existing Games"
      assert_select "span.game-name", game.name
      assert_select "a", "edit"
      assert_select "a", "users"
      assert_select "a", "delete"
      assert_select "a", "New Game"

      get admin_game_users_path(game_id: game.id)
      assert_select "h1", "Lorem Ipsum Admin"
      assert_select "h5", "No Users for game #{game.name}"
      assert_select "a", "Add User"
      assert_select "a", "Back"
    end
  end

  test "Admin page for editing game" do
    DatabaseCleaner.cleaning do
      get new_admin_game_path
      assert_select "h1", "Lorem Ipsum Admin"
      assert_select "h5", "New Game"
      assert_select "input#game_name", nil
      assert_select "input#game_num_rounds", nil
      assert_select "input#game_pause_rounds", nil
      assert_select "input#game_turn_hours", nil
      assert_select "input#game_shuffle", nil
      assert_select "input[value='Create Game']", nil
      assert_select "a", "Cancel"

      game = create_game(shuffle: true)

      get admin_games_path
      assert_select "span.game-name", "#{game.name}", nil
      assert_select "a", "edit"
      assert_select "a", "users"
      assert_select "a", "end"
      assert_select "a", "delete"

      game.update(paused: true)
      get admin_games_path
      assert_select "span.game-name", "#{game.name}", nil
      assert_select "a", "edit"
      assert_select "a", "users"
      assert_select "a", "resume"
      assert_select "a", "end"
      assert_select "a", "delete"

      get edit_admin_game_path(id: game.id)
      assert_select "h1", "Lorem Ipsum Admin"
      assert_select "h5", "Editing game"
      assert_select "input#game_name[value='#{game.name}']", nil
      assert_select "input#game_num_rounds[value='#{game.num_rounds}']", nil
      assert_select "input#game_turn_hours[value='#{game.turn_hours}']", nil
      assert_select "input#game_pause_rounds[value='#{game.pause_rounds}']", nil
      assert_select "input#game_shuffle[value='#{game.shuffle ? 1 : 0}']", nil
      assert_select "input[value='Update Game']", nil
      assert_select "a", "Cancel"

      game.update(ended: Time.now)
      get admin_games_path
      assert_select "span.game-name", "#{game.name} (ended)", nil
    end
  end
end
