require "test_helper"

class TurnsControllerTest < ActionDispatch::IntegrationTest
  DatabaseCleaner.clean

  test "finished turn should send an email" do
    DatabaseCleaner.cleaning do
      ActionMailer::Base.deliveries.clear

      game = create_game
      user1 = create_user({game_id: game.id})
      user2 = create_user({game_id: game.id})

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