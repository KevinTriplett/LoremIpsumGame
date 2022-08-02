require "test_helper"
require 'spec/spec_helper'

class TurnMonitorJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  DatabaseCleaner.clean
  
  test "TurnReminderJob sends turn reminder notification and does not update game.current_player" do
    DatabaseCleaner.cleaning do
      game = create_game
      user1 = create_game_user(game.id)
      user2 = create_game_user(game.id)

      game = Game.find(game.id)
      assert_equal user1.id, game.current_player_id

      ActionMailer::Base.deliveries.clear
      TurnReminderJob.perform_now(user1.id, user1.turns.count)

      game = Game.find(game.id)
      assert_emails 1
      ActionMailer::Base.deliveries.clear
      assert_equal user1.id, game.current_player_id
    end
  end
  
  test "TurnReminderJob does nothing if user takes a turn" do
    DatabaseCleaner.cleaning do
      game = create_game
      user1 = create_game_user(game.id)
      user2 = create_game_user(game.id)
      create_user_turn(user1)

      ActionMailer::Base.deliveries.clear
      TurnReminderJob.perform_now(user1.id, 0)
      assert_emails 0
      ActionMailer::Base.deliveries.clear
    end
  end

  test "TurnFinishJob auto-finishes turn with game.current_player updated" do
    DatabaseCleaner.cleaning do
      game = create_game
      user1 = create_game_user(game.id)
      user2 = create_game_user(game.id)

      game = Game.find(game.id)
      assert_equal user1.id, game.current_player_id

      ActionMailer::Base.deliveries.clear
      TurnFinishJob.perform_now(user1.id, user1.turns.count)

      game = Game.find(game.id)
      assert_emails 1
      ActionMailer::Base.deliveries.clear
      assert_equal user2.id, game.current_player_id
    end
  end
  
  test "TurnFinishJob does nothing if user takes a turn" do
    DatabaseCleaner.cleaning do
      game = create_game
      user1 = create_game_user(game.id)
      user2 = create_game_user(game.id)
      create_user_turn(user1)

      ActionMailer::Base.deliveries.clear
      TurnFinishJob.perform_now(user1.id, 0)
      assert_emails 0
      ActionMailer::Base.deliveries.clear
      assert_equal 1, user1.turns.count
    end
  end
end
