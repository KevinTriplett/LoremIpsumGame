require "application_system_test_case"

class PlayerTest < ApplicationSystemTestCase
  DatabaseCleaner.clean

  test "Player can access pad and submit turn" do
    DatabaseCleaner.start
    
    game = create_game({
      num_rounds: 10,
      turn_hours: 8
    })
    user1 = create_game_user({game_id: game.id})
    user2 = create_game_user({game_id: game.id})
    game.reload
    create_user_turn(user_id: game.current_player_id)
    game.reload
    assert_equal user2.id, game.current_player_id

    visit new_user_turn_path(user_token: user2.token)
    assert_current_path new_user_turn_path(user_token: user2.token)
    sleep(1)
    click_link "Finish Turn"
    page.driver.browser.switch_to.alert.accept
    sleep(1)
    assert_current_path user_turns_path(user_token: user2.token)
    assert_selector ".flash", text: "Turn has been completed and saved - thank you!"
    game.reload
    assert_equal user1.id, game.current_player_id
    assert_equal 2, Turn.all.count
    user2.reload
    assert_equal "test", user2.turns.last.entry

    page.go_back
    sleep(1)
    assert_selector "#finish", text: "Finish Turn"
    click_link "Finish Turn"
    page.driver.browser.switch_to.alert.accept
    sleep(1)
    assert_current_path user_turns_path(user_token: user2.token)
    assert_selector ".flash", text: "Turn has been completed again and saved - thank you!"
    game.reload
    assert_equal user1.id, game.current_player_id
    assert_equal 2, Turn.all.count
    assert_equal user2.id, Turn.all.last.user.id
    user1.reload
    assert_equal "test", user2.turns.last.entry

    sleep(1)
    DatabaseCleaner.clean
  end

  test "Player can access pad and pass" do
    DatabaseCleaner.start
    
    game = create_game({
      num_rounds: 10,
      turn_hours: 8
    })
    user1 = create_game_user({game_id: game.id})
    user2 = create_game_user({game_id: game.id})
    game.reload
    assert_equal user1.id, game.current_player_id

    visit new_user_turn_path(user_token: user1.token)
    assert_current_path new_user_turn_path(user_token: user1.token)
    sleep(1)
    click_link "Pass"
    page.driver.browser.switch_to.alert.accept
    sleep(1)
    assert_current_path user_turns_path(user_token: user1.token)
    assert_selector ".flash", text: "Turn has been completed and saved - thank you!"
    game.reload
    assert_equal user2.id, game.current_player_id
    assert_equal 1, Turn.all.count
    user1.reload
    assert_equal "pass", user1.turns.last.entry

    page.go_back
    sleep(1)
    assert_selector "#finish", text: "Finish Turn"
    click_link "Finish Turn"
    page.driver.browser.switch_to.alert.accept
    sleep(1)
    assert_current_path user_turns_path(user_token: user1.token)
    assert_selector ".flash", text: "Turn has been completed again and saved - thank you!"
    game.reload
    assert_equal user2.id, game.current_player_id
    assert_equal 1, Turn.all.count
    assert_equal user1.id, Turn.all.last.user.id
    user1.reload
    assert_equal "pass", user1.turns.last.entry

    sleep(1)
    DatabaseCleaner.clean
  end
end
