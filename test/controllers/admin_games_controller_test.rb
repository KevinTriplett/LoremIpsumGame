require "test_helper"

class GamesControllerTest < ActionDispatch::IntegrationTest
  DatabaseCleaner.clean

  test "create game should load new user form" do
    DatabaseCleaner.cleaning do
      post admin_games_url, params: {
        game: {
          name: random_game_name,
          num_rounds: 10,
          turn_hours: 24,
          pause_rounds: 0
        }
      }

      follow_redirect!
      assert_equal new_admin_game_user_path, path
    end
  end
end