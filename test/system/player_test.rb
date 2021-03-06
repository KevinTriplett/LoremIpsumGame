require "application_system_test_case"

class PlayerTest < ApplicationSystemTestCase
  test "Player can access [test] pad" do
    DatabaseCleaner.cleaning do
      default_game_days = Rails.configuration.default_game_days
      default_turn_hours = Rails.configuration.default_turn_hours

      visit admin_games_path
      assert "a.btn", "New Game"
      click_link "New Game"

      assert_current_path new_admin_game_path
      fill_in "Game Name", with: "Game 1"
      fill_in "Number of days for game (#{default_game_days})", with: "33"
      fill_in "Number of hours per turn (#{default_turn_hours})", with: "7"
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

  test "Admin can add and edit game user" do
    DatabaseCleaner.cleaning do
      default_game_days = Rails.configuration.default_game_days
      default_turn_hours = Rails.configuration.default_turn_hours

      visit admin_games_path
      click_link "New Game"

      assert_current_path new_admin_game_path
      fill_in "Game Name", with: "Game 1"
      fill_in "Number of days for game (#{default_game_days})", with: "33"
      fill_in "Number of hours per turn (#{default_turn_hours})", with: "7"
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
      click_link "edit"

      assert_current_path edit_admin_game_user_path(game_id: game.id, id: user.id)
      assert_selector "h5", text: "Editing user"
      click_link "Cancel"

      assert_current_path admin_game_users_path(game_id: game.id)
      click_link "edit"

      assert_current_path edit_admin_game_user_path(game_id: game.id, id: user.id)
      fill_in "Name", with: random_user_name
      click_button "Update User"

      assert_current_path admin_game_users_path(game_id: game.id)
      assert_selector ".flash", text: "#{last_random_user_name} has been saved"
      click_link "Back"
      assert_current_path admin_games_path
    end
  end

  test "Adding game with same name and user with same email presents errors" do
    DatabaseCleaner.cleaning do
      game = create_game
      user = create_user(game_id: game.id)

      visit admin_games_path
      click_link "New Game"

      assert_current_path new_admin_game_path
      fill_in "Game Name", with: game.name
      click_button "Create Game"
      assert_current_path new_admin_game_path
      assert_selector ".alert", text: "Please review the problems below:"
      assert_selector ".form-group.game_name .invalid-feedback", text: "name must be unique"

      visit admin_game_users_path(game_id: game.id)
      click_link "Add User"

      assert_current_path new_admin_game_user_path(game_id: game.id)
      fill_in "Name", with: random_user_name
      fill_in "Email", with: user.email
      click_button "Create User"
      assert_current_path new_admin_game_user_path(game_id: game.id)
      assert_selector ".alert", text: "Please review the problems below:"
      assert_selector ".form-group.user_email .invalid-feedback", text: "email must be unique"
    end
  end

  test "Editing game with same name and user with same email does not present errors" do
    DatabaseCleaner.cleaning do
      game = create_game
      user = create_user(game_id: game.id)

      visit edit_admin_game_path(id: game.id)
      fill_in "game[game_days]", with: "22"
      fill_in "game[turn_hours]", with: "12"
      click_button "Update Game"
      assert_current_path admin_games_path
      assert_selector ".flash", text: "#{game.name} has been saved"

      visit edit_admin_game_user_path(game_id: game.id, id: user.id)
      fill_in "Name", with: random_user_name
      click_button "Update User"

      user = User.find(user.id)
      assert_current_path admin_game_users_path(game_id: game.id)
      assert_selector ".flash", text: "#{user.name} has been saved"
    end
  end

  test "Deleting user and game" do
    DatabaseCleaner.cleaning do
      game = create_game
      user = create_game_user(game.id)

      visit admin_game_users_path(game_id: game.id)
      click_link "delete"
      page.driver.browser.switch_to.alert.accept
      assert_selector ".flash", text: "User deleted"
      game.reload
      assert_equal 0, game.users.count
      
      visit admin_games_path
      click_link "delete"
      page.driver.browser.switch_to.alert.accept
      assert_selector ".flash", text: "Game deleted"
      assert_equal 0, Game.all.count
    end
  end

  test "Play user as admin" do
    DatabaseCleaner.cleaning do
      game = create_game
      user = create_game_user(game.id)

      visit admin_game_users_path(game_id: game.id)
      click_link "play"
      
      assert_current_path new_user_turn_path(user_token: user.token)
    end
  end
end
