require 'test_helper'

class GameTest < MiniTest::Spec
  DatabaseCleaner.clean

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

  it "returns hours for turn reminder" do
    DatabaseCleaner.cleaning do
      game = create_game({
        turn_hours: 12
      })
      user = create_user(game_id: game.id)

      game.reload
      assert_equal 6.hours, game.turn_reminder_hours
    end
  end

  it "returns hours for turn auto finish" do
    DatabaseCleaner.cleaning do
      game = create_game({
        turn_hours: 12
      })
      user = create_user(game_id: game.id)

      game.reload
      assert_equal 15.hours, game.turn_autofinish_hours
    end
  end
end