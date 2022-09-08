require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  DatabaseCleaner.clean

  test "add first user to game should send two emails" do
    DatabaseCleaner.cleaning do
      game = create_game

      ActionMailer::Base.deliveries.clear
      assert_emails 2 do
        post admin_game_users_url(game_id: game.id), params: {
          user: {
            name: random_user_name,
            email: random_email,
            game_id: game.id
          }
        }
      end
      ActionMailer::Base.deliveries.clear

      follow_redirect!
      assert_equal new_admin_game_user_path, path
    end
  end

  test "add second user to game should send one email" do
    DatabaseCleaner.cleaning do
      game = create_game
      create_game_user(game_id: game.id)

      ActionMailer::Base.deliveries.clear
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