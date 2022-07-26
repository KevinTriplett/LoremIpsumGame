require "test_helper"

class AdminFlowsTest < ActionDispatch::IntegrationTest
    
  test "admin page with no games" do
    DatabaseCleaner.start
    get admin_games_path
    assert_select "h1", "Lorem Ipsum"
    assert_select "h5", "No Existing Games"
    DatabaseCleaner.clean
  end

  test "admin page with games" do
    DatabaseCleaner.start
    create_game

    get admin_games_path
    assert_select "h5", "Existing Games"
    assert_select "span.game-name", last_random_game_name
    assert_select "a", "edit"
    assert_select "a", "users"
    assert_select "a", "delete"
    assert_select "a", "New Game"
    DatabaseCleaner.clean
  end

  test "admin page for game users when no users assigned to game" do
    DatabaseCleaner.start
    game = create_game

    get admin_game_users_path(game_id: game.id)
    assert_select "h1", "Lorem Ipsum"
    assert_select "h5", "No Users for game #{last_random_game_name}"
    assert_select "a", "Add User"
    DatabaseCleaner.clean
  end

  test "admin page for game users when users assigned to game" do
    DatabaseCleaner.start
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
    DatabaseCleaner.clean
  end
end
