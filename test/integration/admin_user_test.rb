require "test_helper"

class AdminGameTest < ActionDispatch::IntegrationTest
  DatabaseCleaner.clean

  test "Admin page with game and user" do
    DatabaseCleaner.cleaning do
      game = create_game
      user = create_game_user(game_id: game.id)

      get admin_game_users_path(game_id: game.id)
      assert_select "h1", "Lorem Ipsum Admin"
      assert_select "h5", "Users for game #{game.name}"
      assert_select "li a", user.name
      assert_select "a", "play"
      assert_select "a", "edit"
      assert_select "a", "delete"
      assert_select "a", "Add User"
      assert_select "a", "Back"
    end
  end

  test "Admin page for editing user" do
    DatabaseCleaner.cleaning do
      game = create_game

      get new_admin_game_user_path(game_id: game.id)
      assert_select "h1", "Lorem Ipsum Admin"
      assert_select "h5", "New User for #{game.name}"
      assert_select "input#user_name", nil
      assert_select "input#user_email", nil
      assert_select "input[value='Create User']", nil
      assert_select "a", "Done"

      user1 = create_game_user({game_id: game.id})
      user2 = create_game_user({game_id: game.id})

      get admin_game_users_path(game_id: game.id)
      assert_select "h1", "Lorem Ipsum Admin"
      assert_select "h5", "Users for game #{game.name}"
      assert_select "li a", user1.name
      assert_select "li a", user2.name
      assert_select "a", "play"
      assert_select "a", "edit"
      assert_select "a", "delete"
      assert_select "a", "Add User"
      assert_select "a", "Back"

      get edit_admin_game_user_path(game_id: game.id, token: user1.token)
      assert_select "h1", "Lorem Ipsum Admin"
      assert_select "h5", "Editing user"
      assert_select "input#user_name[value='#{user1.name}']", nil
      assert_select "input#user_email[value='#{user1.email}']", nil
      assert_select "input[value='Update User']", nil
      assert_select "a", "Cancel"
    end
  end
end
