require 'test_helper'

class UserTest < MiniTest::Spec
  it "Finds the next user (no rollover)" do
    game = Game.create(name: "game")
    user1 = User.create(name: "John John", email: "abc@xyz.com", game_id: game.id)
    user2 = User.create(name: "Jill Jill", email: "cba@xyz.com", game_id: game.id)
    user3 = User.create(name: "Jack Jack", email: "dbd@xyz.com", game_id: game.id)

    next_player = User.next_player(user2.id, game.id)
    assert_equal user3.id, next_player.id
  end

  it "Finds the next user (rollover)" do
    game = Game.create(name: "game")
    user1 = User.create(name: "John John", email: "abc@xyz.com", game_id: game.id)
    user2 = User.create(name: "Jill Jill", email: "cba@xyz.com", game_id: game.id)
    user3 = User.create(name: "Jack Jack", email: "dbd@xyz.com", game_id: game.id)

    next_player = User.next_player(user3.id, game.id)
    assert_equal user1.id, next_player.id
  end
end