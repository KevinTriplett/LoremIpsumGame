require 'test_helper'

class UserTest < MiniTest::Spec
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
end