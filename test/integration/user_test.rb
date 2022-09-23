require "test_helper"

class UserFlowTest < ActionDispatch::IntegrationTest
  DatabaseCleaner.clean

  test "Puppy!" do
    get "/"
    assert_select "p", "COming Soon!\n      \n      (use the link you received in email)"
  end
  
  test "User can unsubscribe" do
    DatabaseCleaner.cleaning do
      game = create_game
      user = create_game_user({game_id: game.id})

      # can finish turn
      get user_unsubscribe_path(token: user.token)
      assert_select "h1", "Lorem Ipsum"
      assert_select "h5", game.name
      assert_select "strong", "Unsubscribe from #{game.name}?"
      assert_select "#unsubscribe", "Unsubscribe"
    end
  end
end
