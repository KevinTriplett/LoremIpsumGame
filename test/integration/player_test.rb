require "test_helper"

class PlayerFlowsTest < ActionDispatch::IntegrationTest
  DatabaseCleaner.clean
  
  test "User turn page with javascript warning" do
    DatabaseCleaner.cleaning do
      game = create_game({
        game_start: Time.now-4.days,
        game_end: Time.now+4.days,
        turn_start: Time.now-4.hours,
        turn_end: Time.now+4.hours
      })
      user1 = create_game_user(game.id)
      user2 = create_game_user(game.id)
      
      get new_user_turn_path(user_token: user1.token)
      assert_select "h1", "Lorem Ipsum"
      assert_select "h5", game.name
      assert_select "p.game-start", "Game Started:\n#{game.game_start.short_date_at_time}"
      assert_select "p.game-end", "Game Ends:\n#{game.game_end.short_date_at_time}"
      assert_select "p.turn-start", "Turn Started:\n#{game.turn_start.time_and_day}"
      assert_select "p.turn-end", "Turn Ends:\n#{game.turn_end.time_and_day}"
      assert_select "#ep", "Something went wrong: unable to access the document 😭(Note: JavaScript is required)"
      assert_select "li.current-player", "#{user1.name}\n <== current player"

      get user_turns_path(user_token: user2.token)
      assert_select "li.current-player", "#{user1.name}\n <== current player"
    end
  end
end
