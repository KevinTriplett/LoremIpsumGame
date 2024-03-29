require "application_system_test_case"

class AdminGamesTest < ApplicationSystemTestCase
  include ActionMailer::TestHelper
  DatabaseCleaner.clean

  test "Admin can create and edit a game" do
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
      game = Game.first
      assert_current_path new_admin_game_user_path(game_id: game.id)
      assert_selector ".flash", text: "#{last_random_game_name} was created"

      sleep(1)
      game = Game.first
      assert_equal "Game 1", game.name
      assert_equal 33, game.num_rounds
      assert_equal 3, game.pause_rounds
      assert_equal 7, game.turn_hours
      assert game.shuffle?

      click_link "Done"
      assert_current_path admin_game_users_path(game_id: game.id)
      click_link "Back"
      assert_current_path admin_games_path
      click_link "edit"
      assert_current_path edit_admin_game_path(id: game.id)

      fill_in "Name", with: random_game_name
      fill_in "Number of Rounds", with: "11"
      fill_in "Pause each N Rounds (zero = no pause)", with: "0"
      fill_in "Hours per Turn", with: "5"
      uncheck "Shuffle"
      click_button "Update Game"
      assert_current_path admin_games_path
      assert_selector ".flash", text: "#{last_random_game_name} was updated"

      game.reload
      assert_equal last_random_game_name, game.name
      assert_equal 11, game.num_rounds
      assert_equal 0, game.pause_rounds
      assert_equal 5, game.turn_hours
      assert !game.shuffle?
    end
  end

  test "Adding game with same name presents errors" do
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
    end
  end

  test "Can pause and resume a game" do
    DatabaseCleaner.cleaning do
      game = create_game
      user = create_game_user(game_id: game.id, admin: true)
      visit new_user_turn_path(user_token: user.token)

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

      visit admin_games_path
      ActionMailer::Base.deliveries.clear
      click_link "pause"
      assert_selector ".flash", text: "#{game.name} has paused"
      game.reload
      assert game.paused?
      assert_nil game.turn_start
      assert_nil game.turn_end
      assert_emails 1
      email = ActionMailer::Base.deliveries.last
      assert_equal email.subject, "Lorem Ipsum - Game paused"
      assert_equal email.to, game.get_admins.pluck(:email)

      ActionMailer::Base.deliveries.clear
      click_link "resume"
      assert_selector ".flash", text: "#{game.name} has resumed"
      game.reload
      assert !game.paused?
      assert game.turn_start
      assert game.turn_end
      assert_emails 1
      email = ActionMailer::Base.deliveries.last
      assert_equal email.subject, "Lorem Ipsum - Yay! It's Your Turn"
      assert_equal email.to, [game.current_player.email]
      ActionMailer::Base.deliveries.clear
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

  test "Sending group alert email" do
    DatabaseCleaner.cleaning do
      game = create_game
      user1 = create_game_user({game_id: game.id})
      user2 = create_game_user({game_id: game.id})
      
      subject = "This is an alert"
      body = "Spoon too big"

      visit admin_games_path
      click_link "email"
      assert_current_path new_admin_game_email_path(game_id: game.id)
      click_link "Cancel"
      assert_current_path admin_games_url

      click_link "email"
      assert_current_path new_admin_game_email_path(game_id: game.id)
      click_button "Send Email"
      assert_selector ".alert", text: "Please review the problems below:"
      assert_selector ".form-group.email_subject .invalid-feedback", text: "subject must be filled"
      assert_selector ".form-group.email_body .invalid-feedback", text: "body must be filled"

      
      fill_in "Subject", with: subject
      fill_in "Body", with: body

      ActionMailer::Base.deliveries.clear
      click_button "Send Email"
      assert_current_path admin_games_path
      assert_selector ".flash", text: "Email was sent for '#{game.name}'"
      assert_emails 2
      email = ActionMailer::Base.deliveries.last
      assert_equal email.subject, "Lorem Ipsum - " + subject
      assert_equal email.body, body
      assert_equal email.to, [user2.email]
      email = ActionMailer::Base.deliveries.first
      assert_equal email.to, [user1.email]
      ActionMailer::Base.deliveries.clear
    end
  end
end
