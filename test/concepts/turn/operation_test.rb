require 'test_helper'
require 'spec/spec_helper'

class TurnOperationTest < MiniTest::Spec
  include ActionMailer::TestHelper

  describe "TurnOperation" do
    DatabaseCleaner.clean

    # ------------------
    # happy path tests
    it "timestamps game when started" do
      DatabaseCleaner.cleaning do
        game = create_game
        user = create_game_user({game_id: game.id})
        game.reload
        assert_nil game.started
        assert_nil game.turn_start
        assert_nil game.turn_end

        create_user_turn({user_id: user.id})
        game.reload
        assert game.started
        assert game.turn_start
        assert game.turn_end
      end
    end

    it "timestamps game when ended" do
      DatabaseCleaner.cleaning do
        game = create_game({num_rounds: 2})
        user1 = create_game_user({game_id: game.id})
        user2 = create_game_user({game_id: game.id})
        game.reload
        assert_nil game.ended

        create_user_turn(user_id: game.current_player_id)
        game.reload
        assert_nil game.ended
        create_user_turn(user_id: game.current_player_id)
        game.reload
        assert_nil game.ended
        create_user_turn(user_id: game.current_player_id)
        game.reload
        assert_nil game.ended
        create_user_turn(user_id: game.current_player_id)
        game.reload
        assert game.ended
      end
    end

    it "Creates {Turn} model when given valid attributes" do
      DatabaseCleaner.cleaning do
        game = create_game
        user = create_game_user({game_id: game.id})

        result = Turn::Operation::Create.call(
          params: {
            turn: {}
          },
          user_id: user.id,
          game_id: user.game_id
        )

        assert result.success?

        turn = result[:model]
        assert_equal user.id, turn.user_id
        assert_equal turn.id, user.turns.first.id
        assert_equal turn.round, 1
        assert_equal "test", turn.entry
      end
    end

    it "Does not change current_player_id attribute when turn finished and only one player" do
      DatabaseCleaner.cleaning do
        game = create_game
        user = create_game_user({game_id: game.id})
        game.reload
        assert_equal user.id, game.current_player_id

        Turn::Operation::Create.call(
          params: {
            turn: {}
          },
          user_id: user.id,
          game_id: user.game_id
        )

        game.reload
        assert_equal user.id, game.current_player_id
      end
    end

    it "Updates current_player_id attribute when turn finished (no rollover)" do
      DatabaseCleaner.cleaning do
        game = create_game
        user1 = create_game_user({game_id: game.id})
        user2 = create_game_user({game_id: game.id})
        user3 = create_game_user({game_id: game.id})
        game.update(current_player_id: user1.id)

        Turn::Operation::Create.call(
          params: {
            turn: {}
          },
          user_id: user1.id,
          game_id: user1.game_id
        )

        game.reload
        assert_equal user2.id, game.current_player_id
        
        Turn::Operation::Create.call(
          params: {
            turn: {}
          },
          user_id: user2.id,
          game_id: user2.game_id
        )

        game.reload
        assert_equal user3.id, game.current_player_id
      end
    end

    it "resets the reminded flag on the new current_player" do
      DatabaseCleaner.cleaning do
        game = create_game
        user1 = create_game_user({game_id: game.id})
        user2 = create_game_user({game_id: game.id})
        user3 = create_game_user({game_id: game.id})
        game.update(current_player_id: user1.id)

        user1.update(reminded: true)
        user2.update(reminded: true)
        user3.update(reminded: true)

        create_user_turn(user_id: game.current_player_id)
        [user1,user2,user3].each(&:reload)
        # always resets the new current_player, not the previous current_player
        assert user1.reminded
        assert !user2.reminded
        assert user3.reminded
        
        create_user_turn(user_id: game.current_player_id)
        [user1,user2,user3].each(&:reload)
        # always resets the new current_player, not the previous current_player
        assert user1.reminded
        assert !user2.reminded
        assert !user3.reminded

        create_user_turn(user_id: game.current_player_id)
        [user1,user2,user3].each(&:reload)
        # always resets the new current_player, not the previous current_player
        assert !user1.reminded
        assert !user2.reminded
        assert !user3.reminded
      end
    end

    it "Shuffles players and updates current_player_id when round finished" do
      DatabaseCleaner.cleaning do
        game = create_game
        user1 = create_game_user({game_id: game.id})
        user2 = create_game_user({game_id: game.id})
        user3 = create_game_user({game_id: game.id})

        game.reload
        assert_equal [0,1,2], game.users.order(created_at: :asc).pluck(:play_order)
        assert_equal game.players.first.id, game.current_player_id

        game.players.pluck(:id).each do |uid|
          assert_equal uid, game.current_player_id
          assert_equal 1, game.round
          create_user_turn(user_id: game.current_player_id)
          game.reload
        end
        assert_equal 2, game.round
        assert_equal game.players.first.id, game.current_player_id
      end
    end

    it "Updates turn start/end datetime attributes" do
      DatabaseCleaner.cleaning do
        game = create_game
        user = create_game_user({game_id: game.id})
        game.reload
        assert_nil game.started
        assert_nil game.turn_start
        assert_nil game.turn_end

        create_user_turn(user_id: game.current_player_id)

        game.reload
        assert game.turn_start.present?
        assert game.turn_end.present?
        assert_equal game.turn_end, game.turn_start + game.turn_hours.hours
      end
    end

    it "Sends an email to current_player on turn creation" do
      DatabaseCleaner.cleaning do
        game = create_game
        user1 = create_game_user({game_id: game.id})
        user2 = create_game_user({game_id: game.id})
        user3 = create_game_user({game_id: game.id})

        game.reload
        ActionMailer::Base.deliveries.clear
        assert_emails 1 do
          Turn::Operation::Create.call(
            params: {
              turn: {}
            },
            user_id: game.current_player_id,
            game_id: game.id
          )
        end

        game.reload
        assert_equal user2.name, game.current_player.name
        email = ActionMailer::Base.deliveries.last
        assert_equal email.subject, "Lorem Ipsum - Yay! It's Your Turn"
        assert_match /#{game.current_player.name}/, email.body.encoded
        assert_match /#{get_magic_link(game.current_player)}/, email.body.encoded
        assert_match /#{get_unsubscribe_link(game.current_player)}/, email.header['List-Unsubscribe'].inspect
          ActionMailer::Base.deliveries.clear
      end
    end

    it "Sends only one email to all players on last turn finished" do
      DatabaseCleaner.cleaning do
        turn_start = Time.now - 4.hours
        turn_end = turn_start + 4.hours
        game = create_game({
          num_rounds: 1,
          turn_start: turn_start,
          turn_end: turn_end,
          turn_hours: 4
        })
        user1 = create_game_user({game_id: game.id})
        user2 = create_game_user({game_id: game.id})
        user3 = create_game_user({game_id: game.id})
    
        ActionMailer::Base.deliveries.clear
        Turn::Operation::Create.call(
          params: {
            turn: {}
          },
          user_id: user1.id,
          game_id: user1.game_id
        )
        assert_emails 1

        Turn::Operation::Create.call(
          params: {
            turn: {}
          },
          user_id: user2.id,
          game_id: user2.game_id
        )
        assert_emails 2
        
        ActionMailer::Base.deliveries.clear
        Turn::Operation::Create.call(
          params: {
            turn: {}
          },
          user_id: user3.id,
          game_id: user3.game_id
        )
        assert_emails 3

        email = ActionMailer::Base.deliveries.last
        assert_equal email.subject, "Lorem Ipsum - It's Done! Time to Celebrate!"

        ActionMailer::Base.deliveries.clear
        Turn::Operation::Create.call(
          params: {
            turn: {}
          },
          user_id: user3.id,
          game_id: user3.game_id
        )
        assert_emails 0
        ActionMailer::Base.deliveries.clear

      end
    end

    it "Updates round number only when all turns finished" do
      DatabaseCleaner.cleaning do
        game = create_game
        user1 = create_game_user({game_id: game.id})
        user2 = create_game_user({game_id: game.id})
        user3 = create_game_user({game_id: game.id})

        Turn::Operation::Create.call(
          params: {
            turn: {}
          },
          user_id: user1.id,
          game_id: user1.game_id
        )
        game.reload
        assert_equal 1, game.round

        Turn::Operation::Create.call(
          params: {
            turn: {}
          },
          user_id: user2.id,
          game_id: user2.game_id
        )
        game.reload
        assert_equal 1, game.round
        
        Turn::Operation::Create.call(
          params: {
            turn: {}
          },
          user_id: user3.id,
          game_id: user3.game_id
        )
        game.reload
        assert_equal 2, game.round
      end
    end

    it "Pauses game every pre-configured rounds" do
      DatabaseCleaner.cleaning do
        game = create_game({
          num_rounds: 6,
          pause_rounds: 2
        })
        user1 = create_game_user({game_id: game.id})
        user2 = create_game_user({game_id: game.id, admin: true})
        user3 = create_game_user({game_id: game.id, admin: true})

        previous_round = game.round
        (1..game.num_rounds).each do |i|
          game.reload
          ActionMailer::Base.deliveries.clear
          (1..game.users.count).each do
            game.reload
            assert previous_round == game.round
            create_user_turn(user_id: game.current_player_id)
          end
          game.reload
          assert previous_round == game.round - 1
          previous_round = game.round
          email = ActionMailer::Base.deliveries.last
          if game.round > game.num_rounds
            assert !game.paused?
            assert_emails 5
            assert_equal email.subject, "Lorem Ipsum - It's Done! Time to Celebrate!"
            assert_equal email.to, [game.users.order(id: :asc).last.email]
            assert_nil email.cc
          elsif !game.pause_this_round?
            assert !game.paused?
            assert_emails 3
            assert_equal email.subject, "Lorem Ipsum - Yay! It's Your Turn"
            assert_equal email.to, [game.current_player.email]
            assert_equal email.cc.to_set, game.get_admins.pluck(:email).to_set
          else
            assert game.paused?
            assert_emails 3
            assert_equal email.subject, "Lorem Ipsum - Game paused"
            assert_equal email.to.to_set, game.get_admins.pluck(:email).to_set
            assert_nil email.cc
            assert_nil game.turn_start
            assert_nil game.turn_end
          end
          ActionMailer::Base.deliveries.clear
        end
      end
    end

    it "Does not pause game if configured to zero :pause_rounds" do
      DatabaseCleaner.cleaning do
        game = create_game({
          num_rounds: 4,
          pause_rounds: 0
        })
        user1 = create_game_user({game_id: game.id, admin: true})
        user2 = create_game_user({game_id: game.id})
        user3 = create_game_user({game_id: game.id})

        (1..game.num_rounds).each do
          ActionMailer::Base.deliveries.clear
          (1..game.users.count).each do
            game.reload
            create_user_turn(user_id: game.current_player_id)
          end
          game.reload
          assert !game.paused?
          email = ActionMailer::Base.deliveries.last
          if game.round > game.num_rounds
            assert_emails 5
            assert_equal email.subject, "Lorem Ipsum - It's Done! Time to Celebrate!"
            assert_nil email.cc
          else
            assert_emails 3
            assert_equal email.subject, "Lorem Ipsum - Yay! It's Your Turn"
            assert_equal email.cc.to_set, game.get_admins.pluck(:email).to_set
          end
          ActionMailer::Base.deliveries.clear
        end
      end
    end

    it "Playing all rounds ends the game" do
      DatabaseCleaner.cleaning do
        game = create_game(num_rounds: 2)
        user1 = create_game_user({game_id: game.id})
        user2 = create_game_user({game_id: game.id})
        user3 = create_game_user({game_id: game.id})
        game.reload

        create_user_turn(user_id: game.current_player_id)
        game.reload
        assert_equal 1, game.round
        assert !game.ended?

        create_user_turn(user_id: game.current_player_id)
        game.reload
        assert_equal 1, game.round
        assert !game.ended?
        
        create_user_turn(user_id: game.current_player_id)
        game.reload
        assert_equal 2, game.round
        assert !game.ended?

        create_user_turn(user_id: game.current_player_id)
        game.reload
        assert_equal 2, game.round
        assert !game.ended?

        create_user_turn(user_id: game.current_player_id)
        game.reload
        assert_equal 2, game.round
        assert !game.ended?

        create_user_turn(user_id: game.current_player_id)
        game.reload
        assert_equal 3, game.round
        assert game.ended?
      end
    end

    it "All players passing consecutively ends the game" do
      DatabaseCleaner.cleaning do
        game = create_game
        user1 = create_game_user({game_id: game.id})
        user2 = create_game_user({game_id: game.id})
        user3 = create_game_user({game_id: game.id})
        game.reload

        create_user_turn(user_id: game.current_player_id, pass: false)
        game.reload
        assert_equal 1, game.round
        assert !game.ended?

        create_user_turn(user_id: game.current_player_id, pass: true)
        game.reload
        assert_equal 1, game.round
        assert !game.ended?
        
        create_user_turn(user_id: game.current_player_id, pass: false)
        game.reload
        assert_equal 2, game.round
        assert !game.ended?

        create_user_turn(user_id: game.current_player_id, pass: false)
        game.reload
        assert_equal 2, game.round
        assert !game.ended?

        create_user_turn(user_id: game.current_player_id, pass: true)
        game.reload
        assert_equal 2, game.round
        assert !game.ended?

        create_user_turn(user_id: game.current_player_id, pass: true)
        game.reload
        assert_equal 3, game.round
        assert !game.ended?

        create_user_turn(user_id: game.current_player_id, pass: true)
        game.reload
        assert_equal 3, game.round
        assert game.ended?
      end
    end

    it "Player deleted allows the game to end" do
      DatabaseCleaner.cleaning do
        game = create_game({num_rounds: 2})
        user1 = create_game_user({game_id: game.id})
        user2 = create_game_user({game_id: game.id})
        user3 = create_game_user({game_id: game.id})

        game.reload
        create_user_turn(user_id: game.current_player_id)
        game.reload
        assert !game.ended?
        create_user_turn(user_id: game.current_player_id)
        game.reload
        assert !game.ended?
        create_user_turn(user_id: game.current_player_id)
        game.reload
        assert !game.ended?

        User::Operation::Delete.call({
          params: {
            token: user1.token
          }
        })

        game.reload
        assert !game.ended?
        create_user_turn(user_id: game.current_player_id)
        game.reload
        assert !game.ended?
        create_user_turn(user_id: user2.id)
        game.reload
        assert game.ended?
      end
    end

    it "Player added allows the game to end" do
      DatabaseCleaner.cleaning do
        game = create_game({num_rounds: 2})
        user1 = create_game_user({game_id: game.id})
        user2 = create_game_user({game_id: game.id})

        game.reload
        assert !game.ended?
        create_user_turn(user_id: game.current_player_id)
        game.reload
        assert !game.ended?
        create_user_turn(user_id: game.current_player_id)
        game.reload
        assert !game.ended?

        user3 = create_game_user({game_id: game.id})
        game.reload
        create_user_turn(user_id: game.current_player_id)
        game.reload
        assert !game.ended?
        create_user_turn(user_id: game.current_player_id)
        game.reload
        assert !game.ended?
        create_user_turn(user_id: game.current_player_id)
        game.reload
        assert game.ended?
      end
    end

    # ------------------
    # failure tests    
    it "Fails with invalid parameters" do
      DatabaseCleaner.cleaning do
        result = Turn::Operation::Create.call(params: {})

        assert !result.success?
        assert_nil(result["result.contract.default"])
      end
    end
  end
end