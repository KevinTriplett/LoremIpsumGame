require "application_system_test_case"

class PlayerTest < ApplicationSystemTestCase
  DatabaseCleaner.clean

  test "Player can access [test] pad" do
    DatabaseCleaner.cleaning do
      game = create_game({
        game_start: Time.now.utc-4.days,
        game_end: Time.now.utc+4.days,
        turn_start: Time.now.utc-5.hours,
        turn_end: Time.now.utc+3.hours,
        turn_hours: 8
      })
      user1 = create_game_user(game.id)
      user2 = create_game_user(game.id)

      visit new_user_turn_path(user_token: user1.token)
      assert_current_path new_user_turn_path(user_token: user1.token)

      assert_selector "h1", text: "Lorem Ipsum"
      assert_selector "h5", text: game.name
      assert_selector ".game-end", text: game.game_end.dow_short_date
      assert_selector ".game-ends", text: "in 3 days"
      assert_selector ".turn-end", text: game.turn_end.dow_time
      assert_selector ".time-left", text: "2 hours, 59 minutes"
      assert_selector ".current-player-name", text: user1.name
      assert_selector "#ep", text: ""
      assert_selector "li.current-player", text: "#{user1.name} <== current player"
    end
  end
end
