require 'test_helper'

class GameTest < MiniTest::Spec
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

  it "checks for game ended" do
    DatabaseCleaner.cleaning do
      game_end = Time.now + 1.minute
      game = Game.new({
        game_end: game_end
      })
      assert !game.ended?

      game.game_end = Time.now - 1.minute
      assert game.ended?
    end
  end

  it "returns if no_reminder_yet" do
    DatabaseCleaner.cleaning do
      turn_end = Time.now + 8.hours + 1.minute
      game = Game.new({
        turn_end: turn_end,
        turn_hours: 16
      })
      assert game.no_reminder_yet?

      game.turn_end = Time.now + 8.hours - 1.minute
      assert !game.no_reminder_yet?
    end
  end

end