require "application_system_test_case"

class AdminGamesTest < ApplicationSystemTestCase
  test "Admin can create a game and add a user" do
    DatabaseCleaner.cleaning do
      visit admin_games_path
      assert "a.btn", "New Game"
      click_link "New Game"

      assert_current_path new_admin_game_path
      fill_in "Game Name", with: "Game 1"
      fill_in "Number of days for game", with: "33"
      fill_in "Number of hours per turn", with: "7"
      click_button "Create Game"

      game = Game.first
      assert_equal "Game 1", game.name
      assert_equal 33, game.game_days
      assert_equal 7, game.turn_hours

      assert_current_path new_admin_game_user_path(game_id: game.id)
      assert "h5", "New User for #{game.name}"
      fill_in "Name", with: random_user_name
      fill_in "Email", with: random_email
      click_button "Create User"

      game = Game.first
      user = game.users.first
      assert_equal 1, game.users.count
      assert_equal last_random_user_name, user.name
      assert_equal last_random_email, user.email

      assert_current_path new_admin_game_user_path(game_id: game.id)
      click_link "Done"
      assert_current_path admin_game_users_path(game_id: game.id)
    end
  end

  test "Admin can add a user to a game" do
    DatabaseCleaner.cleaning do
      visit admin_games_path
      click_link "New Game"

      assert_current_path new_admin_game_path
      fill_in "Game Name", with: "Game 1"
      fill_in "Number of days for game", with: "33"
      fill_in "Number of hours per turn", with: "7"
      click_button "Create Game"

      game = Game.first
      assert_equal "Game 1", game.name
      assert_equal 33, game.game_days
      assert_equal 7, game.turn_hours

      assert_current_path new_admin_game_user_path(game_id: game.id)
      assert "h5", "New User for #{game.name}"
      fill_in "Name", with: random_user_name
      fill_in "Email", with: random_email
      click_button "Create User"

      game = Game.first
      user = game.users.first
      assert_equal 1, game.users.count
      assert_equal last_random_user_name, user.name
      assert_equal last_random_email, user.email

      assert_current_path new_admin_game_user_path(game_id: game.id)
      click_link "Done"
      assert_current_path admin_game_users_path(game_id: game.id)
    end
  end
end
