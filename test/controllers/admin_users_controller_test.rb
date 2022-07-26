require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  DatabaseCleaner.clean

  test "add user to game should send an email" do
    DatabaseCleaner.cleaning do
      ActionMailer::Base.deliveries.clear

      game = create_game
      assert_emails 1 do
        post admin_game_users_url(game_id: game.id), params: {
          user: {
            name: random_user_name,
            email: random_email,
            game_id: game.id
          }
        }
      end
      
      ActionMailer::Base.deliveries.clear
    end
  end
end