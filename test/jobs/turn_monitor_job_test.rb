require "test_helper"
require 'spec/spec_helper'

class TurnMonitorJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  DatabaseCleaner.clean
  
  test "that TurnMonitorJob sends turn reminder notification and does not update game.current_player" do
    DatabaseCleaner.cleaning do
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
    end
  end
  
  test "that TurnMonitorJob auto-finishes turn with game.current_player updated" do
    DatabaseCleaner.cleaning do
      game_start = Time.now - 1.days
      turn_start = Time.now - 4.hours - 1.minute
      turn_end = turn_start + 2.hours
      game_end = turn_end + 1.minute
      game = create_game({
        game_start: game_start,
        game_end: game_end,
        turn_start: turn_start,
        turn_end: turn_end,
        turn_hours: 2
      })
      user1 = create_game_user(game.id)
      user2 = create_game_user(game.id)

      game = Game.find(game.id)
      assert !game.last_turn?
      assert_equal user1.id, game.current_player_id
      ActionMailer::Base.deliveries.clear
      TurnMonitorJob.perform_now(user1.id)

      game = Game.find(game.id)
      assert_equal user2.id, game.current_player_id
      assert_emails 1
      ActionMailer::Base.deliveries.clear
    end
  end
  
  test "that TurnMonitorJob does not auto-finish last turn" do
    DatabaseCleaner.cleaning do
      game_start = Time.now - 1.days
      turn_start = Time.now - 4.hours
      turn_end = turn_start + 4.hours
      game_end = turn_end - 1.minute
      game = create_game({
        game_start: game_start,
        game_end: game_end,
        turn_start: turn_start,
        turn_end: turn_end,
        turn_hours: 4
      })
      user1 = create_game_user(game.id)
      user2 = create_game_user(game.id)

      game = Game.find(game.id)
      assert game.last_turn?
      assert_equal user1.id, game.current_player_id
      assert_not_nil game.game_start
      assert_not_nil game.game_end

      ActionMailer::Base.deliveries.clear
      TurnMonitorJob.perform_now(user1.id)

      game = Game.find(game.id)
      assert_equal user1.id, game.current_player_id
      assert_emails 0
      ActionMailer::Base.deliveries.clear
    end
  end
end
