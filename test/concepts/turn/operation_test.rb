require 'test_helper'
require 'spec/spec_helper'

class TurnOperationTest < MiniTest::Spec

    # happy path tests
    it "Creates {Turn} model when given valid attributes" do
        game = create_game
        user = create_user(game_id: game.id)

        result = Turn::Operation::Create.wtf?(params: {
            turn: {
            }},
            user_id: user.id
        )

        assert_equal true, result.success?

        turn = result[:model]
        assert_equal user.id, turn.user_id
    end

    it "Updates current_player_id attribute on last game model (no rollover)" do
        game = create_game
        user1 = create_user(game_id: game.id)
        user2 = create_user(game_id: game.id)
        user3 = create_user(game_id: game.id)
        
        result = Turn::Operation::Create.wtf?(params: {
            turn: {
            }},
            user_id: user2.id
        )

        game = Game.find(game.id)
        assert_equal last_random_game_name, game.name
        assert_equal user3.id, game.current_player_id
    end

    it "Updates current_player_id attribute on last game model (rollover)" do
        game = create_game
        user1 = create_user(game_id: game.id)
        user2 = create_user(game_id: game.id)
        user3 = create_user(game_id: game.id)
        
        result = Turn::Operation::Create.wtf?(params: {
            turn: {
            }},
            user_id: user3.id
        )

        game = Game.find(game.id)
        assert_equal user1.id, game.current_player_id
    end

    it "Initializes game start/end datetime attributes" do
        game = create_game
        user1 = create_user(game_id: game.id)
        user2 = create_user(game_id: game.id)

        result = Turn::Operation::Create.wtf?(params: {
            turn: {
            }},
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
        user = create_user(game_id: game.id)
        
        result = Turn::Operation::Create.wtf?(params: {
            turn: {
            }},
            user_id: user.id
        )

        game = Game.find(game.id)
        assert_equal time_start, game.game_start
        assert_equal time_end, game.game_end
    end

    it "Updates turn start/end datetime attributes" do
        game = create_game
        user = create_user(game_id: game.id)
        game = Game.find(game.id)
        
        result = Turn::Operation::Create.wtf?(params: {
            turn: {
            }},
            user_id: user.id
        )

        game = Game.find(game.id)
        assert_equal true, game.turn_start.present?
        assert_equal true, game.turn_end.present?
        assert_equal game.turn_end, game.turn_start + Rails.configuration.default_turn_hours.hours
    end

    # failure tests    
    it "Fails with invalid parameters" do
        result = Turn::Operation::Create.wtf?(params: {})
    
        assert_equal false, result.success?
        assert_nil(result["result.contract.default"])
    end
end