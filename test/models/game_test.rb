require 'test_helper'

class GameTest < MiniTest::Spec
  include ActionMailer::TestHelper
  DatabaseCleaner.clean

  it "Finds the next user (no rollover)" do
    DatabaseCleaner.cleaning do
      game1 = create_game
      game2 = create_game

      user1 = create_game_user(game_id: game1.id)
      user3 = create_game_user(game_id: game2.id)
      user2 = create_game_user(game_id: game1.id)
      user4 = create_game_user(game_id: game2.id)
      user3 = create_game_user(game_id: game1.id)
      user5 = create_game_user(game_id: game2.id)

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
      game1.reload
      assert_equal [0,1,2], game1.users.order(id: :asc).pluck(:play_order)

      game2 = create_game
      user4 = create_game_user(game_id: game2.id)
      user5 = create_game_user(game_id: game2.id)
      user6 = create_game_user(game_id: game2.id)
      game2.reload
      assert_equal [0,1,2], game2.users.order(id: :asc).pluck(:play_order)

      game1.reload
      assert_equal user1.id, game1.current_player_id
      game1.update(current_player_id: user3.id)
      assert_equal user1.id, game1.next_player_id
    end
  end

  it "checks for passes this round" do
    DatabaseCleaner.cleaning do
      game = create_game(shuffle: true)
      user1 = create_game_user(game_id: game.id)
      user2 = create_game_user(game_id: game.id)
      user3 = create_game_user(game_id: game.id)
      game.reload
      game.round -= 1
      assert game.no_passes_this_round?
      assert_equal [0,1,2], game.users.order(id: :asc).pluck(:play_order)

      create_user_turn(user_id: user1.id)
      create_user_turn(user_id: user2.id)
      create_user_turn(user_id: user3.id)
      game.reload
      game.round -= 1
      assert game.no_passes_this_round?
      assert_equal [1,0,2], game.users.order(id: :asc).pluck(:play_order)

      create_user_turn(user_id: user1.id)
      create_user_turn(user_id: user2.id, pass: true)
      create_user_turn(user_id: user3.id)
      game.reload
      game.round -= 1
      assert !game.no_passes_this_round?
      assert_equal [1,0,2], game.users.order(id: :asc).pluck(:play_order)
      game.round -= 1
    end
  end

  it "checks for pause" do
    DatabaseCleaner.cleaning do
      game = create_game({
        pause_rounds: 0,
        num_rounds: 9,
        round: 1
      })
      assert !game.pause_this_round?
      game.update(pause_rounds: 3)
      game.reload
      assert !game.pause_this_round?
      game.update(round: 3)
      game.reload
      assert game.pause_this_round?
      game.update(round: 9)
      game.reload
      assert !game.pause_this_round?
      game.update(num_rounds: 10)
      game.reload
      assert game.pause_this_round?
    end
  end

  it "checks for ended" do
    DatabaseCleaner.cleaning do
      game = create_game({
        ended: Time.now
      })
      assert game.ended?

      game.update(ended: nil)
      assert !game.ended?
    end
  end

  it "starts and stops turn" do
    DatabaseCleaner.cleaning do
      game = Game.new(turn_hours: 1)
      assert_nil game.started
      assert_nil game.turn_start
      assert_nil game.turn_end

      game.start_turn
      assert game.started
      assert game.turn_start
      assert game.turn_end

      started = game.started
      turn_start = game.turn_start
      turn_end = game.turn_end

      game.start_turn
      assert_equal started, game.started
      assert turn_start != game.turn_start
      assert turn_end != game.turn_end

      game.stop_turn
      assert game.started
      assert_nil game.turn_start
      assert_nil game.turn_end
    end
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

  it "gets admins" do
    DatabaseCleaner.cleaning do
      game = create_game
      user1 = create_game_user({name: "user1", game_id: game.id})
      user2 = create_game_user({name: "user2", game_id: game.id, admin: true})
      user3 = create_game_user({name: "user3", game_id: game.id})
      user4 = create_game_user({name: "user4", game_id: game.id, admin: true})

      assert_equal [user2.id,user4.id].to_set, game.get_admins.pluck(:id).to_set
    end
  end

  it "reminds users of turns only once when time" do
    DatabaseCleaner.cleaning do
      turn_end = Time.now + 4.hours - 1.minute
      game1 = create_game({
        turn_end: turn_end,
        turn_hours: 8
      })
      user1 = create_game_user({game_id: game1.id})
      user2 = create_game_user({game_id: game1.id})

      game2 = create_game({
        turn_end: turn_end,
        turn_hours: 8
      })
      user3 = create_game_user({game_id: game2.id})
      user4 = create_game_user({game_id: game2.id})

      ActionMailer::Base.deliveries.clear
      Game.remind_current_players
      assert_emails 2
      last_user = game2.players.first
      email = ActionMailer::Base.deliveries.last
      assert_equal email.subject, "Lorem Ipsum - Reminder: It's Your Turn"
      assert_match /#{last_user.name}/, email.body.encoded
      assert_match /#{get_magic_link(last_user)}/, email.body.encoded
      assert_match /#{get_unsubscribe_link(last_user)}/, email.header['List-Unsubscribe'].inspect
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

      Game.remind_current_players
      assert_emails 0
    end
  end

  it "does not remind users of turns when not time" do
    DatabaseCleaner.cleaning do
      turn_end = Time.now + 4.hours + 1.minute
      game1 = create_game({
        turn_end: turn_end,
        turn_hours: 8
      })
      user1 = create_game_user({game_id: game1.id})
      user2 = create_game_user({game_id: game1.id})

      game2 = create_game({
        turn_end: turn_end,
        turn_hours: 8
      })
      user3 = create_game_user({game_id: game2.id})
      user4 = create_game_user({game_id: game2.id})

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

  it "does not remind users of turns when game ended" do
    DatabaseCleaner.cleaning do
      turn_end = Time.now - 4.hours - 1.minute
      game = create_game({
        turn_end: turn_end,
        turn_hours: 8
      })
      user1 = create_game_user({game_id: game.id})
      user2 = create_game_user({game_id: game.id})
      game.update(ended: Time.now)

      ActionMailer::Base.deliveries.clear
      Game.remind_current_players
      assert_emails 0
    end
  end

  it "does auto-finish turns if game not ended" do
    DatabaseCleaner.cleaning do
      turn_end = Time.now - 6.hours - 1.minute
      game = create_game({
        turn_end: turn_end,
        turn_hours: 8
      })
      user1 = create_game_user({game_id: game.id})
      user2 = create_game_user({game_id: game.id})

      ActionMailer::Base.deliveries.clear
      Game.auto_finish_turns
      assert_emails 2
    end
  end

  it "does remind users of turns if game not ended" do
    DatabaseCleaner.cleaning do
      turn_end = Time.now - 4.hours - 1.minute
      game = create_game({
        turn_end: turn_end,
        turn_hours: 8
      })
      user1 = create_game_user({game_id: game.id})
      user2 = create_game_user({game_id: game.id})

      ActionMailer::Base.deliveries.clear
      Game.remind_current_players
      assert_emails 1
    end
  end

  it "does not auto-finish turns when game ended" do
    DatabaseCleaner.cleaning do
      turn_end = Time.now - 6.hours - 1.minute
      game = create_game({
        turn_end: turn_end,
        turn_hours: 8
      })
      user1 = create_game_user({game_id: game.id})
      user2 = create_game_user({game_id: game.id})
      game.update(ended: Time.now)

      ActionMailer::Base.deliveries.clear
      Game.auto_finish_turns
      assert_emails 0
    end
  end

  it "auto finishes turns only once when time" do
    DatabaseCleaner.cleaning do
      turn_end = Time.now - 1.hour - 1.minute
      game1 = create_game({
        turn_end: turn_end,
        turn_hours: 4
      })
      user1 = create_game_user({game_id: game1.id})
      user2 = create_game_user({game_id: game1.id})

      game2 = create_game({
        turn_end: turn_end,
        turn_hours: 4
      })
      user3 = create_game_user({game_id: game2.id})
      user4 = create_game_user({game_id: game2.id})

      ActionMailer::Base.deliveries.clear
      Game.auto_finish_turns
      assert_emails 4
      email = ActionMailer::Base.deliveries.last
      assert_equal email.subject, "Lorem Ipsum - Your turn was finished for you"
      ActionMailer::Base.deliveries.clear

      [user1,user2,user3,user4].each(&:reload)
      assert_equal 1, user1.turns.count
      assert_equal 0, user2.turns.count
      assert_equal 1, user3.turns.count
      assert_equal 0, user4.turns.count

      assert_emails 0
      Game.auto_finish_turns
      assert_emails 0
      ActionMailer::Base.deliveries.clear
    end
  end

  it "does not auto finish turns when not time" do
    DatabaseCleaner.cleaning do
      turn_end = Time.now - 1.hour + 1.minute
      game1 = create_game({
        turn_end: turn_end,
        turn_hours: 4
      })
      user1 = create_game_user({game_id: game1.id})
      user2 = create_game_user({game_id: game1.id})

      game2 = create_game({
        turn_end: turn_end,
        turn_hours: 4
      })
      user3 = create_game_user({game_id: game2.id})
      user4 = create_game_user({game_id: game2.id})

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

  it "checks for round finished" do
    DatabaseCleaner.cleaning do
      game1 = create_game
      user1 = create_game_user({game_id: game1.id})
      user2 = create_game_user({game_id: game1.id})
      user3 = create_game_user({game_id: game1.id})
      
      game2 = create_game
      user4 = create_game_user({game_id: game2.id})
      user5 = create_game_user({game_id: game2.id})

      game1.reload
      create_user_turn({
        user_id: game1.current_player_id,
        game_id: game1.id
      })
      game1.update(current_player_id: game1.next_player_id)
      assert !game1.round_finished?
      assert !game2.round_finished?

      game1.reload
      create_user_turn({
        user_id: game1.current_player_id,
        game_id: game1.id
      })
      game1.update(current_player_id: game1.next_player_id)
      assert !game1.round_finished?
      assert !game2.round_finished?

      game1.reload
      create_user_turn({
        user_id: game1.current_player_id,
        game_id: game1.id
      })
      assert game1.round_finished?
      assert !game2.round_finished?
    end
  end

  it "checks for players finished" do
    DatabaseCleaner.cleaning do
      game1 = create_game
      user1 = create_game_user({game_id: game1.id})
      user2 = create_game_user({game_id: game1.id})
      user3 = create_game_user({game_id: game1.id})
      game1.reload
      
      game2 = create_game
      user4 = create_game_user({game_id: game2.id})
      user5 = create_game_user({game_id: game2.id})
      create_user_turn(user_id: user4.id)
      create_user_turn(user_id: user5.id)
      game2.reload

      create_user_turn(user_id: game1.current_player_id, pass: true)
      game1.reload
      game2.reload
      assert !game1.players_finished?
      assert !game2.players_finished?

      create_user_turn(user_id: game1.current_player_id, pass: false)
      game1.reload
      game2.reload
      assert !game1.players_finished?
      assert !game2.players_finished?

      create_user_turn(user_id: game1.current_player_id, pass: true)
      game1.reload
      game2.reload
      assert !game1.players_finished?
      assert !game2.players_finished?

      create_user_turn(user_id: game1.current_player_id, pass: true)
      game1.reload
      game2.reload
      assert !game1.players_finished?
      assert !game2.players_finished?

      create_user_turn(user_id: game1.current_player_id, pass: true)
      game1.reload
      game2.reload
      assert game1.players_finished?
      assert !game2.players_finished?
    end
  end

  it "shuffles player order for odd number of players" do
    DatabaseCleaner.cleaning do
      game = create_game(shuffle: true)
      user1 = create_game_user({game_id: game.id})
      user2 = create_game_user({game_id: game.id})

      game.reload
      assert_equal [0,1], game.users.order(id: :asc).pluck(:play_order)
      (0..10).each do
        game.shuffle_players
        game.reload
        assert_equal [0,1], game.users.order(id: :asc).pluck(:play_order)
      end

      user3 = create_game_user({game_id: game.id})
      user4 = create_game_user({game_id: game.id})
      user5 = create_game_user({game_id: game.id})
      game.reload
      assert_equal [0,1,2,3,4], game.users.order(id: :asc).pluck(:play_order)

      game.update(round: 2)
      game.shuffle_players
      game.reload
      assert_equal [0,2,4,1,3], game.users.order(id: :asc).pluck(:play_order)

      game.update(round: 3)
      game.shuffle_players
      game.reload
      assert_equal [1,0,4,3,2], game.users.order(id: :asc).pluck(:play_order)

      game.update(round: 4)
      game.shuffle_players
      game.reload
      assert_equal [2,0,3,1,4], game.users.order(id: :asc).pluck(:play_order)
    end
  end

  it "shuffles player order for even number of players" do
    DatabaseCleaner.cleaning do
      game = create_game(shuffle: true)
      user1 = create_game_user({game_id: game.id})
      user2 = create_game_user({game_id: game.id})
      user3 = create_game_user({game_id: game.id})
      user4 = create_game_user({game_id: game.id})
      user5 = create_game_user({game_id: game.id})
      user6 = create_game_user({game_id: game.id})
      game.reload
      assert_equal [0,1,2,3,4,5], game.users.order(id: :asc).pluck(:play_order)

      game.update(round: 2)
      game.shuffle_players
      game.reload
      assert_equal [0,2,4,1,3,5], game.users.order(id: :asc).pluck(:play_order)

      game.update(round: 3)
      game.shuffle_players
      game.reload
      assert_equal [1,5,2,3,0,4], game.users.order(id: :asc).pluck(:play_order)

      game.update(round: 4)
      game.shuffle_players
      game.reload
      assert_equal [2,5,4,1,0,3], game.users.order(id: :asc).pluck(:play_order)
    end
  end

  it "does not shuffle players when shuffle flag false" do
    DatabaseCleaner.cleaning do
      game = create_game
      user1 = create_game_user({game_id: game.id})
      user2 = create_game_user({game_id: game.id})
      user3 = create_game_user({game_id: game.id})
      user4 = create_game_user({game_id: game.id})
      user5 = create_game_user({game_id: game.id})
      game.reload
      assert_equal [0,1,2,3,4], game.users.order(id: :asc).pluck(:play_order)

      game.update(round: 2)
      game.shuffle_players
      game.reload
      assert_equal [0,1,2,3,4], game.users.order(id: :asc).pluck(:play_order)
      game.shuffle_players
      game.reload
      assert_equal [0,1,2,3,4], game.users.order(id: :asc).pluck(:play_order)
    end
  end

  it "gets player names who played since a datetime (passes)" do
    DatabaseCleaner.cleaning do
      game = create_game
      user1 = create_game_user({name: "user1", game_id: game.id})
      user2 = create_game_user({name: "user2", game_id: game.id})
      user3 = create_game_user({name: "user3", game_id: game.id})
      user4 = create_game_user({name: "user4", game_id: game.id})

      game.reload
      create_user_turn(user_id: game.current_player_id) # 1
      game.reload
      create_user_turn(user_id: game.current_player_id) # 2
      game.reload
      create_user_turn(user_id: game.current_player_id) # 3
      game.reload
      assert_equal [user1.name,user2.name,user3.name], game.get_who_played_since(game.current_player)
      game.reload
      create_user_turn(user_id: game.current_player_id) # 4 and end of 1st round

      game.reload
      players = game.players.pluck(:name)
      create_user_turn(user_id: game.current_player_id) # 1
      game.reload
      create_user_turn(user_id: game.current_player_id, pass: true) # 2 (pass)
      game.reload
      create_user_turn(user_id: game.current_player_id) # 3
      game.reload
      create_user_turn(user_id: game.current_player_id) # 4 and end of 2nd round

      game.reload
      players[1] = players[1] + " (passed)"
      players.slice! players.index(game.current_player.name)
      assert_equal players, game.get_who_played_since(game.current_player)
    end
  end

  it "gets player names who played since a datetime (with passes)" do
    DatabaseCleaner.cleaning do
      game = create_game
      user1 = create_game_user({name: "user1", game_id: game.id})
      user2 = create_game_user({name: "user2", game_id: game.id})
      user3 = create_game_user({name: "user3", game_id: game.id})
      user4 = create_game_user({name: "user4", game_id: game.id})

      game.reload
      create_user_turn(user_id: game.current_player_id)
      game.reload
      create_user_turn(user_id: game.current_player_id, pass: true)
      game.reload
      create_user_turn(user_id: game.current_player_id)
      game.reload
      create_user_turn(user_id: game.current_player_id)

      game.reload
      user1.reload
      assert_equal [user2.name + " (passed)",user3.name,user4.name], game.get_who_played_since(user1)

      game.reload
      create_user_turn(user_id: game.current_player_id)
      game.reload
      create_user_turn(user_id: game.current_player_id)

      game.reload
      user4.reload
      assert_equal [user1.name,user2.name], game.get_who_played_since(user4)
    end
  end
end