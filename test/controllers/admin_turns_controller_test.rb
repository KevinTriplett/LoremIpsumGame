require "test_helper"

class TurnsControllerTest < ActionDispatch::IntegrationTest
  test "finished turn should send an email" do
    DatabaseCleaner.start
    ActionMailer::Base.deliveries.clear

    game = create_game
    result = User::Operation::Create.wtf?(
      params: {
        user: {
          name: random_user_name, 
          email: random_email
        }
      },
      game_id: game.id
    )
    user1 = result[:model]
    user2 = create_user(game_id: game.id)

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