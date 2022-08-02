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
      game = Game.find(game.id)
      assert_equal user1.id, game.current_player_id
      
      get new_user_turn_path(user_token: user1.token)
      assert_select "h1", "Lorem Ipsum"
      assert_select "h5", game.name
      assert_select ".game-start", game.game_start.iso8601
      assert_select ".game-end", game.game_end.iso8601
      assert_select ".turn-start", game.turn_start.iso8601
      assert_select ".turn-end", game.turn_end.iso8601
      assert_select ".time-left", "3 hours, 59 minutes"
      assert_select ".current-player-name", user1.name
      assert_select "#ep", "Something went wrong: unable to access the document 😭(Note: JavaScript is required) 🤔"
      assert_select "li.current-player", "#{user1.name}\n <== current player"

      get user_turns_path(user_token: user2.token)
      assert_select "li.current-player", "#{user1.name}\n <== current player"

      Turn::Operation::Create.call(
        params: {
          turn: {}
        },
        user_id: user1.id
      )
      game = Game.find(game.id)
      assert_equal user2.id, game.current_player_id

      get user_turns_path(user_token: user2.token)
      assert_select ".turn-start", game.turn_start.iso8601
      assert_select ".turn-end", game.turn_end.iso8601
      assert_select ".current-player-name", user2.name
      assert_select "li.current-player", "#{user2.name}\n <== current player"
    end
  end
end
