require "application_system_test_case"

class AdminGamesTest < ApplicationSystemTestCase
  include ActionMailer::TestHelper
  DatabaseCleaner.clean

  test "Admin can create a game and add a user" do
    DatabaseCleaner.cleaning do
      visit admin_games_path
      assert "a.btn", "New Game"
      click_link "New Game"

      assert_current_path new_admin_game_path
      fill_in "Name", with: "Game 1"
      fill_in "Number of Rounds", with: "33"
      fill_in "Pause each N Rounds (zero = no pause)", with: "3"
      fill_in "Hours per Turn", with: "7"
      check "Shuffle"
      click_button "Create Game"

      sleep(1)
      game = Game.first
      assert_equal "Game 1", game.name
      assert_equal 33, game.num_rounds
      assert_equal 3, game.pause_rounds
      assert_equal 7, game.turn_hours
      assert game.shuffle

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
      visit admin_games_path
      click_link "New Game"

      assert_current_path new_admin_game_path
      fill_in "Name", with: "Game 1"
      fill_in "Number of Rounds", with: "22"
      fill_in "Pause each N Rounds (zero = no pause)", with: "0"
      fill_in "Hours per Turn", with: "7"
      click_button "Create Game"

      game = Game.first
      assert_equal "Game 1", game.name
      assert_equal 22, game.num_rounds
      assert_equal 0, game.pause_rounds
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
      user = create_game_user(game_id: game.id)

      visit admin_games_path
      click_link "New Game"

      assert_current_path new_admin_game_path
      fill_in "Name", with: game.name
      fill_in "Number of Rounds", with: "33"
      fill_in "Pause each N Rounds (zero = no pause)", with: "3"
      fill_in "Hours per Turn", with: "7"
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

  test "Editing game and user does not present errors" do
    DatabaseCleaner.cleaning do
      game = create_game
      user = create_game_user(game_id: game.id)

      visit admin_games_path
      assert_no_selector "a", text: "resume"
      click_link "end"
      assert_selector ".flash", text: "#{game.name} has ended"
      game.reload
      assert game.ended?
      click_link "end"
      assert_selector ".flash", text: "#{game.name} has not ended"
      game.reload
      assert !game.ended?

      game.update(paused: true)
      visit admin_games_path
      ActionMailer::Base.deliveries.clear
      click_link "resume"
      assert_selector ".flash", text: "#{game.name} has resumed"
      game.reload
      assert !game.paused?
      assert_emails 1
      email = ActionMailer::Base.deliveries.last
      assert_equal email.subject, "[Lorem Ipsum] Yay! It's Your Turn! 🥳"
      assert_equal email.to, [game.current_player.email]
      ActionMailer::Base.deliveries.clear

      visit edit_admin_game_path(id: game.id)
      fill_in "game[num_rounds]", with: "21"
      fill_in "game[turn_hours]", with: "12"
      click_button "Update Game"
      assert_current_path admin_games_path
      assert_selector ".flash", text: "#{game.name} has been saved"

      visit edit_admin_game_user_path(game_id: game.id, id: user.id)
      fill_in "Name", with: random_user_name
      check "Admin"
      click_button "Update User"

      sleep(1)
      user.reload
      assert user.admin
      assert_current_path admin_game_users_path(game_id: game.id)
      assert_selector ".flash", text: "#{user.name} has been saved"
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

  test "Deleting game" do
    DatabaseCleaner.cleaning do
      game = create_game
      user = create_game_user({game_id: game.id})

      visit admin_games_path
      click_link "delete"
      page.driver.browser.switch_to.alert.accept
      assert_selector ".flash", text: "Game deleted"
      assert_equal 0, Game.all.count
      assert_equal 0, User.all.count
    end
  end

  test "Play user as admin" do
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
