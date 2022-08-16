require 'test_helper'
require 'spec/spec_helper'

class TurnOperationTest < MiniTest::Spec
  include ActionMailer::TestHelper

  describe "TurnOperation" do
    DatabaseCleaner.clean

    # ------------------
    # happy path tests
    it "Game starts with an indefinite turn duration" do
      DatabaseCleaner.cleaning do
        result = Game::Operation::Create.call(params: {
          game: {
            name: random_game_name,
            num_rounds: 3,
            turn_hours: 2
          }
        })
        game = result[:model]
        user = create_user({game_id: game.id})

        game.reload
        assert_nil game.turn_start
        assert_nil game.turn_end
      end
    end

    it "Creates {Turn} model when given valid attributes" do
      DatabaseCleaner.cleaning do
        game = create_game
        user = create_user({game_id: game.id})

        result = Turn::Operation::Create.call(
          params: {
            turn: {}
          },
          user_id: user.id,
          game_id: user.game_id
        )

        assert_equal true, result.success?

        turn = result[:model]
        assert_equal user.id, turn.user_id
        assert_equal turn.id, user.turns.first.id
      end
    end

    it "Does not change current_player_id attribute when turn finished and only one player" do
      DatabaseCleaner.cleaning do
        game = create_game
        user = create_user({game_id: game.id})
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
        user1 = create_user({game_id: game.id})
        user2 = create_user({game_id: game.id})
        user3 = create_user({game_id: game.id})
        game.update(current_player_id: user1.id)

        Turn::Operation::Create.call(
          params: {
            turn: {}
          },
          user_id: user1.id,
          game_id: user1.game_id
        )
        Turn::Operation::Create.call(
          params: {
            turn: {}
          },
          user_id: user2.id,
          game_id: user2.game_id
        )

        game.reload
        assert_equal last_random_game_name, game.name
        assert_equal user3.id, game.current_player_id
      end
    end

    it "resets the reminded flag on the new current_player" do
      DatabaseCleaner.cleaning do
        game = create_game
        user1 = create_user({game_id: game.id})
        user2 = create_user({game_id: game.id})
        user3 = create_user({game_id: game.id})
        game.update(current_player_id: user1.id)

        user1.update(reminded: true)
        user2.update(reminded: true)
        user3.update(reminded: true)
        [user1,user2,user3].each(&:reload)
        # always resets the new current_player, not the previous current_player
        assert user1.reminded
        assert user2.reminded
        assert user3.reminded

        Turn::Operation::Create.call(
          params: {
            turn: {}
          },
          user_id: user1.id,
          game_id: user1.game_id
        )
        [user1,user2,user3].each(&:reload)
        # always resets the new current_player, not the previous current_player
        assert user1.reminded
        assert user2.reminded
        assert user3.reminded
        
        Turn::Operation::Create.call(
          params: {
            turn: {}
          },
          user_id: user2.id,
          game_id: user2.game_id
        )
        [user1,user2,user3].each(&:reload)
        # always resets the new current_player, not the previous current_player
        assert user1.reminded
        assert user2.reminded
        assert user3.reminded

        Turn::Operation::Create.call(
          params: {
            turn: {}
          },
          user_id: user2.id,
          game_id: user2.game_id
        )
        [user1,user2,user3].each(&:reload)
        # always resets the new current_player, not the previous current_player
        assert !user1.reminded
        assert !user2.reminded
        assert !user3.reminded
      end
    end

    it "Shuffles players and updates current_player_id when last turn finished" do
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
          Turn::Operation::Create.call(
            params: {
              turn: {}
            },
            user_id: uid,
            game_id: game.id
          )
          game.reload
        end
        assert_equal 2, game.round
        assert_equal game.players.first.id, game.current_player_id
      end
    end

    it "Updates turn start/end datetime attributes" do
      DatabaseCleaner.cleaning do
        game = create_game
        user = create_user({game_id: game.id})
        game.reload
        assert_equal false, game.turn_start.present?
        assert_equal false, game.turn_end.present?

        Turn::Operation::Create.call(
          params: {
            turn: {}
          },
          user_id: user.id,
          game_id: user.game_id
        )

        game.reload
        assert_equal true, game.turn_start.present?
        assert_equal true, game.turn_end.present?
        assert_equal game.turn_end, game.turn_start + game.turn_hours.hours
      end
    end

    it "Sends an email to current_player on turn creation" do
      DatabaseCleaner.cleaning do
        game = create_game
        user1 = create_user({game_id: game.id})
        user2 = create_user({game_id: game.id})

        ActionMailer::Base.deliveries.clear
        result = Turn::Operation::Create.call(
          params: {
            turn: {}
          },
          user_id: user1.id,
          game_id: user1.game_id
        )

        assert_emails 1
        email = ActionMailer::Base.deliveries.last
        assert_equal email.subject, "[Lorem Ipsum] Yay! It's Your Turn! 🥳"
        assert_match /#{user2.name}/, email.body.encoded
        assert_match /#{get_magic_link(user2)}/, email.body.encoded

        ActionMailer::Base.deliveries.clear
      end
    end

    it "Sends an email to all players on last turn finished" do
      DatabaseCleaner.cleaning do
        turn_start = Time.now - 4.hours
        turn_end = turn_start + 4.hours
        game = create_game({
          num_rounds: 1,
          turn_start: turn_start,
          turn_end: turn_end,
          turn_hours: 4
        })
        user1 = create_user({game_id: game.id})
        user2 = create_user({game_id: game.id})
        user3 = create_user({game_id: game.id})
    
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
        assert_equal email.subject, "[Lorem Ipsum] It's Done! Time to Celebrate! 🎉"
        ActionMailer::Base.deliveries.clear
      end
    end

    it "Updates round number only when all turns finished" do
      DatabaseCleaner.cleaning do
        game = create_game
        user1 = create_user({game_id: game.id})
        user2 = create_user({game_id: game.id})
        user3 = create_user({game_id: game.id})

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

    # ------------------
    # failure tests    
    it "Fails with invalid parameters" do
      DatabaseCleaner.cleaning do
        result = Turn::Operation::Create.call(params: {})

        assert_equal false, result.success?
        assert_nil(result["result.contract.default"])
      end
    end
  end
end