require 'test_helper'

class UserTest < MiniTest::Spec
  include ActionMailer::TestHelper
  DatabaseCleaner.clean

  it "Finds the next user (no rollover)" do
    DatabaseCleaner.cleaning do
      game = create_game
      user1 = create_user(game_id: game.id)
      user2 = create_user(game_id: game.id)
      user3 = create_user(game_id: game.id)

      next_player = User.next_player(user2.id, game.id)
      assert_equal user3.id, next_player.id
    end
  end

  it "Finds the next user (rollover)" do
    DatabaseCleaner.cleaning do
      game = create_game
      user1 = create_user(game_id: game.id)
      user2 = create_user(game_id: game.id)
      user3 = create_user(game_id: game.id)

      next_player = User.next_player(user3.id, game.id)
      assert_equal user1.id, next_player.id
    end
  end

  it "reminds users of turns when time" do
    DatabaseCleaner.cleaning do
      turn_end = Time.now + 4.hours - 1.minute
      game_end = Time.now + 1.day
      game1 = create_game({
        game_end: game_end,
        turn_end: turn_end,
        turn_hours: 8
      })
      user1 = create_game_user(game1.id)
      user2 = create_game_user(game1.id)

      game2 = create_game({
        game_end: game_end,
        turn_end: turn_end,
        turn_hours: 8
      })
      user3 = create_game_user(game2.id)
      user4 = create_game_user(game2.id)

      ActionMailer::Base.deliveries.clear
      User.remind_players
      assert_emails 2
      ActionMailer::Base.deliveries.clear
      assert_equal 0, user1.turns.count
      assert_equal 0, user2.turns.count
      assert_equal 0, user3.turns.count
      assert_equal 0, user4.turns.count
    end
  end

  it "does not remind users of turns when not time" do
    DatabaseCleaner.cleaning do
      turn_end = Time.now + 4.hours + 1.minute
      game_end = Time.now + 1.day
      game1 = create_game({
        game_end: game_end,
        turn_end: turn_end,
        turn_hours: 8
      })
      user1 = create_game_user(game1.id)
      user2 = create_game_user(game1.id)

      game2 = create_game({
        game_end: game_end,
        turn_end: turn_end,
        turn_hours: 8
      })
      user3 = create_game_user(game2.id)
      user4 = create_game_user(game2.id)

      ActionMailer::Base.deliveries.clear
      User.remind_players
      assert_emails 0
      ActionMailer::Base.deliveries.clear
      assert_equal 0, user1.turns.count
      assert_equal 0, user2.turns.count
      assert_equal 0, user3.turns.count
      assert_equal 0, user4.turns.count
    end
  end

  it "auto finishes turns when time" do
    DatabaseCleaner.cleaning do
      turn_end = Time.now - 1.minute
      game_end = Time.now + 1.day
      game1 = create_game({
        game_end: game_end,
        turn_end: turn_end
      })
      user1 = create_game_user(game1.id)
      user2 = create_game_user(game1.id)

      game2 = create_game({
        game_end: game_end,
        turn_end: turn_end
      })
      user3 = create_game_user(game2.id)
      user4 = create_game_user(game2.id)

      ActionMailer::Base.deliveries.clear
      User.auto_finish_turns
      assert_emails 2
      ActionMailer::Base.deliveries.clear
      assert_equal 1, user1.turns.count
      assert_equal 0, user2.turns.count
      assert_equal 1, user3.turns.count
      assert_equal 0, user4.turns.count
    end
  end

  it "does not auto finish turns when not time" do
    DatabaseCleaner.cleaning do
      turn_end = Time.now + 4.hours + 1.minute
      game_end = Time.now + 1.day
      game1 = create_game({
        game_end: game_end,
        turn_end: turn_end,
        turn_hours: 8
      })
      user1 = create_game_user(game1.id)
      user2 = create_game_user(game1.id)

      game2 = create_game({
        game_end: game_end,
        turn_end: turn_end,
        turn_hours: 8
      })
      user3 = create_game_user(game2.id)
      user4 = create_game_user(game2.id)

      ActionMailer::Base.deliveries.clear
      User.auto_finish_turns
      assert_emails 0
      ActionMailer::Base.deliveries.clear
      assert_equal 0, user1.turns.count
      assert_equal 0, user2.turns.count
      assert_equal 0, user3.turns.count
      assert_equal 0, user4.turns.count
    end
  end
end