require "test_helper"
require 'spec/spec_helper'

class TurnMonitorJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper
  
  test "that TurnMonitorJob sends turn reminder notification and does not update game.current_player" do
    turn_start = Time.now - 4.hours + 1.minute
    turn_end = turn_start + 4.hours
    game = create_game({
      turn_start: turn_start,
      turn_end: turn_end,
      turn_hours: 2
    })

    # this operation will update game.current_player_id
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

    game = Game.find(game.id)
    assert_equal user1.id, game.current_player_id

    ActionMailer::Base.deliveries.clear
    TurnMonitorJob.perform_now(user1.id)

    game = Game.find(game.id)
    assert_equal user1.id, game.current_player_id
    assert_emails 1
    ActionMailer::Base.deliveries.clear
  end
  
  test "that TurnMonitorJob auto-finishes turn with game.current_player updated" do
    turn_start = Time.now - 4.hours - 1.minute
    turn_end = turn_start + 2.hours
    game = create_game({
      turn_start: turn_start,
      turn_end: turn_end,
      turn_hours: 2
    })

    # this operation will update game.current_player_id
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

    game = Game.find(game.id)
    assert_equal user1.id, game.current_player_id

    ActionMailer::Base.deliveries.clear
    TurnMonitorJob.perform_now(user1.id)

    game = Game.find(game.id)
    assert_equal user2.id, game.current_player_id
    assert_emails 1
    ActionMailer::Base.deliveries.clear
  end
end
