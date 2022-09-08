require "test_helper"

class PlayerFlowsTest < ActionDispatch::IntegrationTest
  DatabaseCleaner.clean
  
  test "User turn page with javascript warning" do
    DatabaseCleaner.cleaning do
      game = create_game({
        num_rounds: 10,
        started: Time.now-1.day,
        turn_start: Time.now-5.hours,
        turn_end: Time.now+3.hours,
        turn_hours: 8
      })
      user1 = create_game_user({game_id: game.id})
      user2 = create_game_user({game_id: game.id})
      game.update(round: 2)

      game.reload
      assert_equal 10, game.num_rounds
      assert_equal 2, game.round
      assert_equal user1.id, game.current_player_id
      
      # can finish turn
      get new_user_turn_path(user_token: user1.token)
      assert_select "h1", "Lorem Ipsum"
      assert_select "h5", game.name
      assert_select ".game-round", "2 of 10"
      assert_select ".pause-or-end", "Ends:\nin 9 rounds"
      assert_select ".turn-end", game.turn_end.iso8601
      assert_select ".time-left", "2 hrs, 59 mins"
      assert_select "#ep", "Something went wrong: 😭Try refreshing the page 🤓(Note: JavaScript is required) 🤔"
      assert_select "#finish", "Finish Turn"
      assert_select "#pass", "Pass"
      assert_select "li.current-player", "#{user1.name}\n <== current player"

      get user_turns_path(user_token: user2.token)
      assert_select "li.current-player", "#{user1.name}\n <== current player"

      Turn::Operation::Create.call(
        params: {
          turn: {}
        },
        user_id: user1.id,
        game_id: user1.game_id
      )
      game.reload
      assert_equal user2.id, game.current_player_id
      assert_equal 1, user1.turns.count
      assert_equal 0, user2.turns.count

      get user_turns_path(user_token: user2.token)
      assert_select ".game-round", "2 of 10"
      assert_select ".pause-or-end", "Ends:\nin 9 rounds"
      assert_select ".turn-end", game.turn_end.iso8601
      assert_select ".time-left", "7 hrs, 59 mins"
      assert_select "#ep", "Something went wrong: 😭Try refreshing the page 🤓(Note: JavaScript is required) 🤔"
      assert_select "li.current-player", "#{user2.name}\n <== current player"

      Turn::Operation::Create.call(
        params: {
          turn: {}
        },
        user_id: user2.id,
        game_id: user2.game_id
      )
      game.reload
      assert_equal user1.id, game.current_player_id
      assert_equal 1, user1.turns.count
      assert_equal 1, user2.turns.count

      get user_turns_path(user_token: user1.token)
      assert_select ".game-round", "3 of 10"
      assert_select ".pause-or-end", "Ends:\nin 8 rounds"

      game.update(round: game.num_rounds)
      get new_user_turn_path(user_token: user1.token)
      assert_select ".game-round", "10 of 10"
      assert_select ".pause-or-end", "Ends:\nthis round"
    end
  end

  test "User turn page with pause and end" do
    DatabaseCleaner.cleaning do
      game = create_game({
        num_rounds: 9,
        pause_rounds: 0,
        round: 3
      })
      user = create_game_user({game_id: game.id})

      get new_user_turn_path(user_token: user.token)
      assert_select ".game-round", "3 of 9"
      assert_select ".pause-or-end", "Ends:\nin 7 rounds"

      game.update(pause_rounds: 3)
      get new_user_turn_path(user_token: user.token)
      assert_select ".game-round", "3 of 9"
      assert_select ".pause-or-end", "Pauses:\nthis round"

      game.update(round: 4)
      get new_user_turn_path(user_token: user.token)
      assert_select ".game-round", "4 of 9"
      assert_select ".pause-or-end", "Pauses:\nin 3 rounds"

      game.update(round: 9)
      get new_user_turn_path(user_token: user.token)
      assert_select ".game-round", "9 of 9"
      assert_select ".pause-or-end", "Ends:\nthis round"
    end
  end
end
