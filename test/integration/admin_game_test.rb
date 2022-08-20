require "test_helper"

class AdminGameTest < ActionDispatch::IntegrationTest
  DatabaseCleaner.clean

  test "Admin page with no games" do
    get admin_games_path
  
    assert_select "h1", "Lorem Ipsum"
    assert_select "h5", "No Existing Games"
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
      assert_select "h1", "Lorem Ipsum"
      assert_select "h5", "No Users for game #{game.name}"
      assert_select "a", "Add User"
      assert_select "a", "Back"
    end
  end

  test "Admin page for editing game and editing user" do
    DatabaseCleaner.cleaning do

      ##################
      # games
      get new_admin_game_path
      assert_select "h1", "Lorem Ipsum"
      assert_select "h5", "New Game"
      assert_select "input#game_name", nil
      assert_select "input#game_num_rounds", nil
      assert_select "input#game_turn_hours", nil
      assert_select "input[value='Create Game']", nil
      assert_select "a", "Cancel"

      game = create_game

      get admin_games_path
      assert_select "span.game-name", "#{game.name}", nil
      assert_select "a", "edit"
      assert_select "a", "users"
      assert_select "a", "end"
      assert_select "a", "delete"

      get edit_admin_game_path(id: game.id)
      assert_select "h1", "Lorem Ipsum"
      assert_select "h5", "Editing game"
      assert_select "input#game_name[value='#{game.name}']", nil
      assert_select "input#game_num_rounds[value='#{game.num_rounds}']", nil
      assert_select "input#game_turn_hours[value='#{game.turn_hours}']", nil
      assert_select "input[value='Update Game']", nil
      assert_select "a", "Cancel"

      ##################
      # users
      get new_admin_game_user_path(game_id: game.id)
      assert_select "h1", "Lorem Ipsum"
      assert_select "h5", "New User for #{game.name}"
      assert_select "input#user_name", nil
      assert_select "input#user_email", nil
      assert_select "input[value='Create User']", nil
      assert_select "a", "Done"

      user1 = create_user({game_id: game.id})
      user2 = create_user({game_id: game.id})

      get admin_game_users_path(game_id: game.id)
      assert_select "h1", "Lorem Ipsum"
      assert_select "h5", "Users for game #{game.name}"
      assert_select "a", user1.name
      assert_select "a", user2.name
      assert_select "a", "play"
      assert_select "a", "edit"
      assert_select "a", "delete"
      assert_select "a", "Add User"
      assert_select "a", "Back"

      get edit_admin_game_user_path(game_id: game.id, id: user1.id)
      assert_select "h1", "Lorem Ipsum"
      assert_select "h5", "Editing user"
      assert_select "input#user_name[value='#{user1.name}']", nil
      assert_select "input#user_email[value='#{user1.email}']", nil
      assert_select "input[value='Update User']", nil
      assert_select "a", "Cancel"

      game.update(ended: Time.now)
      get admin_games_path
      assert_select "span.game-name", "#{game.name} (ended)", nil
    end
  end
end
