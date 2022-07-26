require "test_helper"

class AdminFlowsTest < ActionDispatch::IntegrationTest

  test "Admin page with no games" do
    DatabaseCleaner.clean
    Game.all.each(&:delete) # for some reason, DatabaseCleaner.clean doesn't do it
    DatabaseCleaner.cleaning do
      get admin_games_path
      assert_select "h1", "Lorem Ipsum"
      assert_select "h5", "No Existing Games"
    end
  end

  test "Admin page with games" do
    DatabaseCleaner.clean
    DatabaseCleaner.cleaning do
      create_game

      get admin_games_path
      assert_select "h5", "Existing Games"
      assert_select "span.game-name", last_random_game_name
      assert_select "a", "edit"
      assert_select "a", "users"
      assert_select "a", "delete"
      assert_select "a", "New Game"
    end
  end

  test "Admin page for game with no users" do
    DatabaseCleaner.clean
    DatabaseCleaner.cleaning do
      game = create_game

      get admin_game_users_path(game_id: game.id)
      assert_select "h1", "Lorem Ipsum"
      assert_select "h5", "No Users for game #{last_random_game_name}"
      assert_select "a", "Add User"
    end
  end

  test "Admin page for game with users" do
    DatabaseCleaner.clean
    DatabaseCleaner.cleaning do
      game = create_game
      user1 = create_game_user(game.id)
      user2 = create_game_user(game.id)

      get admin_game_users_path(game_id: game.id)
      assert_select "h1", "Lorem Ipsum"
      assert_select "h5", "Users for game #{last_random_game_name}"
      assert_select "a", user1.name
      assert_select "a", user2.name
      assert_select "a", "play"
      assert_select "a", "edit"
      assert_select "a", "delete"
      assert_select "a", "Add User"
    end
  end

  test "Admin page for game editing" do
    DatabaseCleaner.clean
    DatabaseCleaner.cleaning do
      game = create_game
      user1 = create_game_user(game.id)
      user2 = create_game_user(game.id)

      get admin_game_users_path(game_id: game.id)
      assert_select "h1", "Lorem Ipsum"
      assert_select "h5", "Users for game #{last_random_game_name}"
    end
  end
end
