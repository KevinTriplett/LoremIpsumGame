require "test_helper"

class TurnsControllerTest < ActionDispatch::IntegrationTest
  DatabaseCleaner.clean

  test "Starting the first turn sets game attributes" do
    DatabaseCleaner.cleaning do
      game = create_game
      user = create_game_user({game_id: game.id})

      game.reload
      assert_nil game.turn_start
      assert_nil game.turn_end
      assert_nil game.started

      get new_user_turn_url(user_token: user.token)

      game.reload
      assert game.turn_start
      assert game.turn_end
      assert game.started
    end
  end

  test "finished turn should send an email" do
    DatabaseCleaner.cleaning do
      game = create_game
      user1 = create_game_user({game_id: game.id})
      user2 = create_game_user({game_id: game.id})

      ActionMailer::Base.deliveries.clear
      assert_emails 1 do
        post user_turns_url(user_token: user1.token), params: {
          turn: {},
          game_id: game.id
        }
      end
      ActionMailer::Base.deliveries.clear
    end
  end
end