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
      user1 = create_game_user(game_id: game1.id)
      user2 = create_game_user(game_id: game1.id)
      user3 = create_game_user(game_id: game1.id)

      game2 = create_game
      user4 = create_game_user(game_id: game2.id)
      user5 = create_game_user(game_id: game2.id)
      user6 = create_game_user(game_id: game2.id)

      game1.reload
      assert_equal user1.id, game1.current_player_id
      assert_equal [0,1,2], game1.users.pluck(:play_order)
      game1.update(current_player_id: user3.id)
      assert_equal user1.id, game1.next_player_id
    end
  end

  it "check for last turn" do
    DatabaseCleaner.cleaning do
      game = Game.new({
        num_rounds: 2,
        round: 1
      })
      assert !game.last_turn?

      game.round += 1
      assert game.last_turn?
    end
  end

  it "checks for game ended" do
    game = Game.new({
      num_rounds: 2,
      round: 2
    })
    assert !game.game_ended?

    game.round += 1
    assert game.game_ended?
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
      game1 = create_game({
        turn_end: turn_end,
        turn_hours: 8
      })
      user1 = create_user({game_id: game1.id})
      user2 = create_user({game_id: game1.id})

      game2 = create_game({
        turn_end: turn_end,
        turn_hours: 8
      })
      user3 = create_user({game_id: game2.id})
      user4 = create_user({game_id: game2.id})

      ActionMailer::Base.deliveries.clear
      Game.remind_current_players
      assert_emails 2
      last_user = game2.players.last
      email = ActionMailer::Base.deliveries.last
      assert_equal email.subject, "[Lorem Ipsum] Reminder: It's Your Turn 😅"
      assert_match /#{last_user.name}/, email.body.encoded
      assert_match /#{get_magic_link(last_user)}/, email.body.encoded
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
      game1 = create_game({
        turn_end: turn_end,
        turn_hours: 8
      })
      user1 = create_user({game_id: game1.id})
      user2 = create_user({game_id: game1.id})

      game2 = create_game({
        turn_end: turn_end,
        turn_hours: 8
      })
      user3 = create_user({game_id: game2.id})
      user4 = create_user({game_id: game2.id})

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
      game1 = create_game({
        turn_end: turn_end,
        turn_hours: 4
      })
      user1 = create_user({game_id: game1.id})
      user2 = create_user({game_id: game1.id})

      game2 = create_game({
        turn_end: turn_end,
        turn_hours: 4
      })
      user3 = create_user({game_id: game2.id})
      user4 = create_user({game_id: game2.id})

      ActionMailer::Base.deliveries.clear
      Game.auto_finish_turns
      assert_emails 4
      email = ActionMailer::Base.deliveries.last
      assert_equal email.subject, "[Lorem Ipsum] Your turn was finished for you 🫣"
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
      game1 = create_game({
        turn_end: turn_end,
        turn_hours: 4
      })
      user1 = create_user({game_id: game1.id})
      user2 = create_user({game_id: game1.id})

      game2 = create_game({
        turn_end: turn_end,
        turn_hours: 4
      })
      user3 = create_user({game_id: game2.id})
      user4 = create_user({game_id: game2.id})

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

  it "checks for players finished" do
    DatabaseCleaner.cleaning do
      game1 = create_game
      user1 = create_user({game_id: game1.id})
      user2 = create_user({game_id: game1.id})
      user3 = create_user({game_id: game1.id})
      
      game2 = create_game
      user4 = create_user({game_id: game2.id})
      user5 = create_user({game_id: game2.id})

      game1.reload
      create_turn({
        user_id: game1.current_player_id,
        game_id: game1.id
      })
      game1.update(current_player_id: game1.next_player_id)
      assert !game1.players_finished?
      assert !game2.players_finished?

      game1.reload
      create_turn({
        user_id: game1.current_player_id,
        game_id: game1.id
      })
      game1.update(current_player_id: game1.next_player_id)
      assert !game1.players_finished?
      assert !game2.players_finished?

      game1.reload
      create_turn({
        user_id: game1.current_player_id,
        game_id: game1.id
      })
      assert game1.players_finished?
      assert !game2.players_finished?
    end
  end

  it "shuffles player order for odd number of players" do
    DatabaseCleaner.cleaning do
      game = create_game
      user1 = create_game_user({game_id: game.id})
      user2 = create_game_user({game_id: game.id})

      game.reload
      assert_equal [0,1], game.users.pluck(:play_order)
      (0..10).each do
        game.shuffle_players
        game.reload
        assert_equal [0,1], game.users.pluck(:play_order)
      end

      user3 = create_game_user({game_id: game.id})
      user4 = create_game_user({game_id: game.id})
      user5 = create_game_user({game_id: game.id})
      game.reload
      assert_equal [0,1,2,3,4], game.users.pluck(:play_order)

      game.update(round: 2)
      game.shuffle_players
      game.reload
      assert_equal [0,3,1,4,2], game.users.pluck(:play_order)

      game.update(round: 3)
      game.shuffle_players
      game.reload
      assert_equal [1,0,4,3,2], game.users.pluck(:play_order)

      game.update(round: 4)
      game.shuffle_players
      game.reload
      assert_equal [1,3,0,2,4], game.users.pluck(:play_order)
    end
  end

  it "shuffles player order for even number of players" do
    DatabaseCleaner.cleaning do
      game = create_game
      user1 = create_game_user({game_id: game.id})
      user2 = create_game_user({game_id: game.id})
      user3 = create_game_user({game_id: game.id})
      user4 = create_game_user({game_id: game.id})
      user5 = create_game_user({game_id: game.id})
      user6 = create_game_user({game_id: game.id})
      game.reload
      assert_equal [0,1,2,3,4,5], game.users.pluck(:play_order)

      game.update(round: 2)
      game.shuffle_players
      game.reload
      assert_equal [0,3,1,4,2,5], game.users.pluck(:play_order)

      game.update(round: 3)
      game.shuffle_players
      game.reload
      assert_equal [4,0,2,3,5,1], game.users.pluck(:play_order)

      game.update(round: 4)
      game.shuffle_players
      game.reload
      assert_equal [4,3,0,5,2,1], game.users.pluck(:play_order)
    end
  end
end