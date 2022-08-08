require 'test_helper'

class GameTest < MiniTest::Spec
  include ActionMailer::TestHelper
  DatabaseCleaner.clean

  it "Finds the next user (no rollover)" do
    DatabaseCleaner.cleaning do
      game1 = create_game
      game2 = create_game

      user1 = create_user(game_id: game1.id)
      user3 = create_user(game_id: game2.id)
      user2 = create_user(game_id: game1.id)
      user4 = create_user(game_id: game2.id)
      user3 = create_user(game_id: game1.id)
      user5 = create_user(game_id: game2.id)

      game1.current_player_id = user2.id
      assert_equal user3.id, game1.next_player_id
    end
  end

  it "Finds the next user (rollover)" do
    DatabaseCleaner.cleaning do
      game1 = create_game
      game2 = create_game

      user1 = create_user(game_id: game1.id)
      user3 = create_user(game_id: game2.id)
      user2 = create_user(game_id: game1.id)
      user4 = create_user(game_id: game2.id)
      user3 = create_user(game_id: game1.id)
      user5 = create_user(game_id: game2.id)

      game1.current_player_id = user3.id
      assert_equal user1.id, game1.next_player_id
    end
  end

  it "check for ! last turn" do
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
      user = create_user(game_id: game.id)

      game.reload
      assert !game.last_turn?
    end
  end

  it "check for last turn" do
    DatabaseCleaner.cleaning do
      game_start = Time.now - 1.days
      turn_start = Time.now - 4.hours - 1.minute
      turn_end = turn_start + 2.hours
      game_end = turn_end - 1.minute
      game = create_game({
        game_start: game_start,
        game_end: game_end,
        turn_start: turn_start,
        turn_end: turn_end,
        turn_hours: 2
      })
      user = create_user(game_id: game.id)

      game.reload
      assert game.last_turn?
    end
  end

  it "checks for ! game ended" do
    game_end = Time.now + 1.minute
    game = Game.new({
      game_end: game_end
    })
    assert !game.ended?
  end

  it "checks for game ended" do
    game_end = Time.now - 1.minute
    game = Game.new({
      game_end: game_end
    })
    assert game.ended?
  end

  it "checks for ! time_to_remind_player" do
    turn_end = Time.now + 8.hours + 1.minute
    game = Game.new({
      turn_end: turn_end,
      turn_hours: 16
    })
    assert !game.time_to_remind_player?
  end

  it "checks for time_to_remind_player" do
    turn_end = Time.now + 8.hours - 1.minute
    game = Game.new({
      turn_end: turn_end,
      turn_hours: 16
    })
    assert game.time_to_remind_player?
  end

  it "checks for ! time_to_finish_turn" do
    turn_end = Time.now - 1.hours + 1.minute
    game = Game.new({
      turn_end: turn_end,
      turn_hours: 4
    })
    assert !game.time_to_finish_turn?
  end

  it "checks for time_to_finish_turn" do
    turn_end = Time.now - 1.hours - 1.minute
    game = Game.new({
      turn_end: turn_end,
      turn_hours: 4
    })
    assert game.time_to_finish_turn?
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
      Game.remind_current_players
      assert_emails 2
      ActionMailer::Base.deliveries.clear

      [user1,user2,user3,user4].each(&:reload)
      assert_equal 0, user1.turns.count
      assert_equal 0, user2.turns.count
      assert_equal 0, user3.turns.count
      assert_equal 0, user4.turns.count

      assert user1.reminded?
      assert user3.reminded?
      assert !user2.reminded?
      assert !user4.reminded?
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
      Game.remind_current_players
      assert_emails 0

      [user1,user2,user3,user4].each(&:reload)
      assert_equal 0, user1.turns.count
      assert_equal 0, user2.turns.count
      assert_equal 0, user3.turns.count
      assert_equal 0, user4.turns.count

      assert !user1.reminded?
      assert !user3.reminded?
      assert !user2.reminded?
      assert !user4.reminded?
    end
  end

  it "auto finishes turns when time" do
    DatabaseCleaner.cleaning do
      turn_end = Time.now - 1.hour - 1.minute
      game_end = Time.now + 1.day
      game1 = create_game({
        game_end: game_end,
        turn_end: turn_end,
        turn_hours: 4
      })
      user1 = create_game_user(game1.id)
      user2 = create_game_user(game1.id)

      game2 = create_game({
        game_end: game_end,
        turn_end: turn_end,
        turn_hours: 4
      })
      user3 = create_game_user(game2.id)
      user4 = create_game_user(game2.id)

      ActionMailer::Base.deliveries.clear
      Game.auto_finish_turns
      assert_emails 2
      ActionMailer::Base.deliveries.clear

      [user1,user2,user3,user4].each(&:reload)
      assert_equal 1, user1.turns.count
      assert_equal 0, user2.turns.count
      assert_equal 1, user3.turns.count
      assert_equal 0, user4.turns.count
    end
  end

  it "does not auto finish turns when not time" do
    DatabaseCleaner.cleaning do
      turn_end = Time.now - 1.hour + 1.minute
      game_end = Time.now + 1.day
      game1 = create_game({
        game_end: game_end,
        turn_end: turn_end,
        turn_hours: 4
      })
      user1 = create_game_user(game1.id)
      user2 = create_game_user(game1.id)

      game2 = create_game({
        game_end: game_end,
        turn_end: turn_end,
        turn_hours: 4
      })
      user3 = create_game_user(game2.id)
      user4 = create_game_user(game2.id)

      ActionMailer::Base.deliveries.clear
      Game.auto_finish_turns
      assert_emails 0

      [user1,user2,user3,user4].each(&:reload)
      assert_equal 0, user1.turns.count
      assert_equal 0, user2.turns.count
      assert_equal 0, user3.turns.count
      assert_equal 0, user4.turns.count
    end
  end
end