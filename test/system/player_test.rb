require "application_system_test_case"

class PlayerTest < ApplicationSystemTestCase
  DatabaseCleaner.clean

  test "Player can access pad and submit turn" do
    DatabaseCleaner.cleaning do
      game = create_game({
        num_rounds: 10,
        turn_start: Time.now.utc-5.hours,
        turn_end: Time.now.utc+3.hours,
        turn_hours: 8
      })
      user1 = create_user({game_id: game.id})
      user2 = create_user({game_id: game.id})

      visit new_user_turn_path(user_token: user1.token)
      assert_current_path new_user_turn_path(user_token: user1.token)

      assert_selector "h1", text: "Lorem Ipsum"
      assert_selector "h5", text: game.name
      assert_selector ".game-ends", text: "in 9 more rounds"
      assert_selector ".turn-end", text: game.turn_end.dow_time
      assert_selector ".time-left", text: "2 hours, 59 minutes"
      assert_selector ".current-player-name", text: user1.name
      assert_selector "#ep", text: ""
      assert_selector "li.current-player", text: "#{user1.name} <== current player"

      # TODO: why does this fail?
      click_link "Finish Turn"
      page.driver.browser.switch_to.alert.accept
      assert_equal 1, Turn.all.count
      assert_equal user1.id, Turn.all.first.user.id
      assert_current_path user_turns_path(user_token: user1.token)

      # TODO: why does this fail?
      # page.go_back
      # click_link "Finish Turn"
      # page.driver.browser.switch_to.alert.accept
      # assert_equal 1, Turn.all.count
      # assert_equal user1.id, Turn.all.first.user.id
    end
  end
end
