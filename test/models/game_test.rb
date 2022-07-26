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
      user = create_game_user(game.id)

      game = Game.find(game.id)
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
      user = create_game_user(game.id)

      game = Game.find(game.id)
      assert game.last_turn?
    end
  end
end