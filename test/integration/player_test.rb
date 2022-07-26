require "test_helper"

class PlayerFlowsTest < ActionDispatch::IntegrationTest
  DatabaseCleaner.clean
  
  test "User turn page with javascript warning" do
    DatabaseCleaner.cleaning do
      game = create_game
      user1 = create_game_user(game.id)
      user2 = create_game_user(game.id)
      
      get new_user_turn_path(user_token: user1.token)
      assert_select "h1", "Lorem Ipsum"
      assert_select "h5", game.name
      assert_select "#ep", "Something went wrong: unable to access the document 😭(Note: JavaScript is required)"
      assert_select "li.current-player", "#{user1.name}\n <== current player"

      get user_turns_path(user_token: user2.token)
      assert_select "li.current-player", "#{user1.name}\n <== current player"
    end
  end
end
