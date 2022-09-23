require "application_system_test_case"

class AdminUsersTest < ApplicationSystemTestCase
  include ActionMailer::TestHelper
  DatabaseCleaner.clean

  test "Admin can add and edit game user" do
    DatabaseCleaner.cleaning do
      game = create_game
      visit new_admin_game_user_path(game_id: game.id)
      assert_current_path new_admin_game_user_path(game_id: game.id)
      assert "h5", "New User for #{game.name}"
      fill_in "Name", with: random_user_name
      fill_in "Email", with: random_email
      check "Admin"
      click_button "Create User"
      assert_current_path new_admin_game_user_path(game_id: game.id)
      assert_selector ".flash", text: "#{last_random_user_name} was created"

      game = Game.first
      user = game.users.first
      assert_equal 1, game.users.count
      assert_equal last_random_user_name, user.name
      assert_equal last_random_email, user.email
      assert user.admin?

      click_link "Done"
      assert_current_path admin_game_users_path(game_id: game.id)
      click_link "edit"

      assert_current_path edit_admin_game_user_path(game_id: game.id, token: user.token)
      assert_selector "h5", text: "Editing user"
      click_link "Cancel"

      assert_current_path admin_game_users_path(game_id: game.id)
      click_link "edit"

      assert_current_path edit_admin_game_user_path(game_id: game.id, token: user.token)
      fill_in "Name", with: random_user_name
      uncheck "Admin"
      click_button "Update User"

      assert_current_path admin_game_users_path(game_id: game.id)
      assert_selector ".flash", text: "#{last_random_user_name} was updated"
      click_link "Back"
      assert_current_path admin_games_path

      user.reload
      assert_equal last_random_user_name, user.name
      assert_equal last_random_email, user.email
      assert !user.admin?
    end
  end

  test "Adding user with same email presents errors" do
    DatabaseCleaner.cleaning do
      game = create_game
      user = create_game_user(game_id: game.id)

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

  test "Editing user does not present errors" do
    DatabaseCleaner.cleaning do
      game = create_game
      user = create_game_user(game_id: game.id)

      visit edit_admin_game_user_path(game_id: game.id, token: user.token)
      fill_in "Name", with: random_user_name
      check "Admin"
      click_button "Update User"

      sleep(1)
      user.reload
      assert user.admin?
      assert_current_path admin_game_users_path(game_id: game.id)
      assert_selector ".flash", text: "#{user.name} was updated"
    end
  end

  test "Deleting user" do
    DatabaseCleaner.cleaning do
      game = create_game
      user = create_game_user({game_id: game.id})

      visit admin_game_users_path(game_id: game.id)
      click_link "delete"
      page.driver.browser.switch_to.alert.accept
      assert_selector ".flash", text: "User deleted"
      game.reload
      assert_equal 0, game.users.count
    end
  end

  test "Playing user" do
    DatabaseCleaner.cleaning do
      game = create_game(num_rounds: 1)
      user = create_game_user({game_id: game.id})

      visit admin_game_users_path(game_id: game.id)
      click_link "play"
      
      assert_current_path new_user_turn_path(user_token: user.token)
      assert_selector "#finish", text: "Finish Turn"
      assert_selector "#pass", text: "Pass"
    end
  end
end
