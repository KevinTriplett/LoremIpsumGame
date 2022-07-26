require "test_helper"
require 'spec/spec_helper'

class TurnMonitorJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper
  
  test "that TurnMonitorJob sends turn reminder notification and does not update game.current_player" do
    DatabaseCleaner.start
    turn_start = Time.now - 4.hours + 1.minute
    turn_end = turn_start + 4.hours
    game = create_game({
      turn_start: turn_start,
      turn_end: turn_end,
      turn_hours: 2
    })

    user1 = create_game_user(game.id)
    user2 = create_game_user(game.id)

    game = Game.find(game.id)
    assert_equal user1.id, game.current_player_id

    ActionMailer::Base.deliveries.clear
    TurnMonitorJob.perform_now(user1.id)

    game = Game.find(game.id)
    assert_equal user1.id, game.current_player_id
    assert_emails 1
    ActionMailer::Base.deliveries.clear
    DatabaseCleaner.clean
  end
  
  test "that TurnMonitorJob auto-finishes turn with game.current_player updated" do
    DatabaseCleaner.start
    turn_start = Time.now - 4.hours - 1.minute
    turn_end = turn_start + 2.hours
    game = create_game({
      turn_start: turn_start,
      turn_end: turn_end,
      turn_hours: 2
    })

    user1 = create_game_user(game.id)
    user2 = create_game_user(game.id)

    game = Game.find(game.id)
    assert_equal user1.id, game.current_player_id

    ActionMailer::Base.deliveries.clear
    TurnMonitorJob.perform_now(user1.id)

    game = Game.find(game.id)
    assert_equal user2.id, game.current_player_id
    assert_emails 1
    ActionMailer::Base.deliveries.clear
    DatabaseCleaner.clean
  end
end
