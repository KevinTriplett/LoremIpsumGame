require "test_helper"

class TurnsControllerTest < ActionDispatch::IntegrationTest
  test "finished turn should send an email" do
    DatabaseCleaner.start
    ActionMailer::Base.deliveries.clear

    game = create_game
    user1 = create_game_user(game.id)
    user2 = create_game_user(game.id)

    assert_emails 1 do
      post user_turns_url(user_token: user1.token), params: {
        turn: {},
        game_id: game.id
      }
    end
    
    ActionMailer::Base.deliveries.clear
    DatabaseCleaner.clean
  end
end