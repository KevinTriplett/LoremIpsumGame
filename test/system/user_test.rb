require "application_system_test_case"

class UserTest < ApplicationSystemTestCase
  DatabaseCleaner.clean

  test "User can unsubscribe" do
    DatabaseCleaner.start
    
    game = create_game
    user1 = create_game_user({game_id: game.id})
    user2 = create_game_user({game_id: game.id})

    visit user_unsubscribe_path(token: user1.token)
    assert_current_path user_unsubscribe_path(token: user1.token)
    click_link "Unsubscribe"
    page.driver.browser.switch_to.alert.accept
    assert_current_path root_path

    sleep(1)
    assert_nil User.find_by_token(user1.token)
    assert_equal user2.id, User.find_by_token(user2.token).id
    DatabaseCleaner.clean
  end
end
