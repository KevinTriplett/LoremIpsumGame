require 'test_helper'
require 'spec/spec_helper'

class TurnOperationTest < MiniTest::Spec
  include ActionMailer::TestHelper

  describe "TurnOperation" do

    before do
      DatabaseCleaner.start
    end

    after do
      DatabaseCleaner.clean
    end

    it "Starts with an indefinite turn duration" do
      game = create_game
      user = create_game_user(game.id)

      game = Game.find(game.id)
      assert_nil game.turn_start
      assert_nil game.turn_end
    end

    # ------------------
    # happy path tests
    it "Creates {Turn} model when given valid attributes" do
      game = create_game
      user = create_game_user(game.id)

      result = Turn::Operation::Create.wtf?(
        params: {
          turn: {}
        },
        user_id: user.id
      )

      assert_equal true, result.success?

      turn = result[:model]
      assert_equal user.id, turn.user_id
    end

    it "Does not update current_player_id attribute when turn finished and only one player" do
      game = create_game
      user = create_game_user(game.id)
      game = Game.find(game.id)
      assert_equal user.id, game.current_player_id

      result = Turn::Operation::Create.wtf?(
        params: {
          turn: {}
        },
        user_id: user.id
      )

      game = Game.find(game.id)
      assert_equal user.id, game.current_player_id
    end

    it "Updates current_player_id attribute when turn finished (no rollover)" do
      game = create_game
      user1 = create_game_user(game.id)
      user2 = create_game_user(game.id)
      user3 = create_game_user(game.id)

      result = Turn::Operation::Create.wtf?(
        params: {
          turn: {}
        },
        user_id: user2.id
      )

      game = Game.find(game.id)
      assert_equal last_random_game_name, game.name
      assert_equal user3.id, game.current_player_id
    end

    it "Updates current_player_id attribute when turn finished (rollover)" do
      game = create_game
      user1 = create_game_user(game.id)
      user2 = create_game_user(game.id)
      user3 = create_game_user(game.id)

      result = Turn::Operation::Create.wtf?(
        params: {
          turn: {}
        },
        user_id: user3.id
      )

      game = Game.find(game.id)
      assert_equal user1.id, game.current_player_id
    end

    it "Initializes game start/end datetime attributes" do
      game = create_game
      user1 = create_game_user(game.id)
      user2 = create_game_user(game.id)
      assert_equal false, game.game_start.present?
      assert_equal false, game.game_end.present?

      result = Turn::Operation::Create.wtf?(
        params: {
          turn: {}
        },
        user_id: user1.id
      )

      game = Game.find(game.id)
      assert_equal true, game.game_start.present?
      assert_equal true, game.game_end.present?
      assert_equal game.game_end, game.game_start + Rails.configuration.default_game_days.days
    end

    it "Does not change game start/end datetime attributes" do
      time_start, time_end = Time.now - 2.days, Time.now + 2.days
      game = create_game(name: random_game_name, game_start: time_start, game_end: time_end)
      user = create_game_user(game.id)

      result = Turn::Operation::Create.wtf?(
        params: {
          turn: {}
        },
        user_id: user.id
      )

      game = Game.find(game.id)
      assert_equal time_start, game.game_start
      assert_equal time_end, game.game_end
    end

    it "Updates turn start/end datetime attributes" do
      game = create_game
      user = create_game_user(game.id)
      game = Game.find(game.id)
      assert_equal false, game.turn_start.present?
      assert_equal false, game.turn_end.present?

      result = Turn::Operation::Create.wtf?(
        params: {
          turn: {}
        },
        user_id: user.id
      )

      game = Game.find(game.id)
      assert_equal true, game.turn_start.present?
      assert_equal true, game.turn_end.present?
      assert_equal game.turn_end, game.turn_start + Rails.configuration.default_turn_hours.hours
    end

    it "Sends an email to current_player on turn creation" do
      game = create_game
      user = create_game_user(game.id)

      ActionMailer::Base.deliveries.clear
      result = Turn::Operation::Create.wtf?(
        params: {
          turn: {}
        },
        user_id: user.id
      )

      assert_emails 1
      ActionMailer::Base.deliveries.clear
    end

    # ------------------
    # failure tests    
    it "Fails with invalid parameters" do
      result = Turn::Operation::Create.wtf?(params: {})

      assert_equal false, result.success?
      assert_nil(result["result.contract.default"])
    end
  end
end