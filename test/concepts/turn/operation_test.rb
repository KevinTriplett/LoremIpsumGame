require 'test_helper'

class TurnOperationTest < MiniTest::Spec
    # TODO: cache _entry
    def valid_entry
        _entry = ""
        Rails.configuration.entry_length_min.times { _entry += "x" }
        _entry
    end

    it "Creates {Turn} model when given valid attributes" do
        game = Game.create(name: "game")
        user = User.create(name: "John John", email: "abc@xyz.com", game_id: game.id)

        entry = valid_entry
        result = Turn::Operation::Create.wtf?(params: {turn: {
            entry: valid_entry, 
            user_id: user.id, 
            game_id: game.id
        }})

        assert_equal true, result.success?

        model = result[:turn]
        assert_equal valid_entry, model.entry
        assert_equal user.id, model.user_id
        assert_equal game.id, model.game_id
    end

    it "Updates current_player_id attribute on last game model (no rollover)" do
        game = Game.create(name: "game")
        user1 = User.create(name: "John John", email: "abc@xyz.com", game_id: game.id)
        user2 = User.create(name: "Jill Jill", email: "cba@xyz.com", game_id: game.id)
        user3 = User.create(name: "Jack Jack", email: "dbd@xyz.com", game_id: game.id)
        
        result = Turn::Operation::Create.wtf?(params: {turn: {
            entry: valid_entry, 
            user_id: user2.id, 
            game_id: game.id
        }})

        game = Game.find(game.id)
        assert_equal "game", game.name
        assert_equal user3.id, game.current_player_id
    end

    it "Updates current_player_id attribute on last game model (rollover)" do
        game = Game.create(name: "game")
        user1 = User.create(name: "John John", email: "abc@xyz.com", game_id: game.id)
        user2 = User.create(name: "Jill Jill", email: "cba@xyz.com", game_id: game.id)
        user3 = User.create(name: "Jack Jack", email: "dbd@xyz.com", game_id: game.id)
        
        result = Turn::Operation::Create.wtf?(params: {turn: {
            entry: valid_entry, 
            user_id: user3.id, 
            game_id: game.id
        }})

        game = Game.find(game.id)
        assert_equal user1.id, game.current_player_id
    end

    it "Initializes game start/end datetime attributes" do
        game = Game.create(name: "game")
        user1 = User.create(name: "John John", email: "abc@xyz.com", game_id: game.id)
        user2 = User.create(name: "Jill Jill", email: "cba@xyz.com", game_id: game.id)

        result = Turn::Operation::Create.wtf?(params: {turn: {
            entry: valid_entry, 
            user_id: user1.id, 
            game_id: game.id
        }})

        game = Game.find(game.id)
        assert_equal true, game.game_start.present?
        assert_equal true, game.game_end.present?
        assert_equal game.game_end, game.game_start + Rails.configuration.game_days.days
    end

    it "Does not change game start/end datetime attributes" do
        time_start, time_end = Time.now, Time.now + Rails.configuration.game_days.days
        game = Game.create(name: "game", game_start: time_start, game_end: time_end)
        user = User.create(name: "John John", email: "abc@xyz.com", game_id: game.id)

        result = Turn::Operation::Create.wtf?(params: {turn: {
            entry: valid_entry, 
            user_id: user.id, 
            game_id: game.id
        }})

        game = Game.find(game.id)
        assert_equal time_start, game.game_start
        assert_equal time_end, game.game_end
    end

    it "Updates turn start/end datetime attributes" do
        game = Game.create(name: "game")
        user = User.create(name: "John John", email: "abc@xyz.com", game_id: game.id)
        game = Game.find(game.id)
        
        result = Turn::Operation::Create.wtf?(params: {turn: {
            entry: valid_entry, 
            user_id: user.id, 
            game_id: game.id
        }})

        game = Game.find(game.id)
        assert_equal true, game.turn_start.present?
        assert_equal true, game.turn_end.present?
        assert_equal game.turn_end, game.turn_start + Rails.configuration.turn_hours.hours
    end

    it "Fails with invalid parameters" do
        result = Turn::Operation::Create.wtf?(params: {})
    
        assert_equal false, result.success?
        assert_nil(result["result.contract.default"])
    end
        
    it "Fails with empty entry attribute" do
        result = Turn::Operation::Create.wtf?(params: {turn: {
            entry: "", 
            user_id: 1234, 
            game_id: 5678
        }})

        assert_equal false, result.success?
        assert_equal({:entry=>["must be filled"]}, result["result.contract.default"].errors.to_h)
    end

    it "Fails when entry is too short" do
        entry = ""
        (Rails.configuration.entry_length_min - 1).times { entry += "x" }
        result = Turn::Operation::Create.wtf?(params: {turn: {
            entry: entry, 
            user_id: 1234, 
            game_id: 5678
        }})

        assert_equal false, result.success?
        msg = "too short, must be more than " + Rails.configuration.entry_length_min.to_s + " letters"
        assert_equal({:entry=>[msg]}, result["result.contract.default"].errors.to_h)
    end

    it "Fails when entry is too long" do
        entry = ""
        (Rails.configuration.entry_length_max + 1).times { entry += "x" }
        result = Turn::Operation::Create.wtf?(params: {turn: {
            entry: entry, 
            user_id: 1234, 
            game_id: 5678
        }})

        assert_equal false, result.success?
        msg = "too long, must be less than " + Rails.configuration.entry_length_max.to_s + " letters"
        assert_equal({:entry=>[msg]}, result["result.contract.default"].errors.to_h)
    end

    it "Fails with no user_id attribute" do
        result = Turn::Operation::Create.wtf?(params: {turn: {
            entry: valid_entry, 
            user_id: nil, 
            game_id: 5678
        }})

        assert_equal false, result.success?
        assert_equal({:user_id=>["must be filled"]}, result["result.contract.default"].errors.to_h)
    end

    it "Fails with non-integer user_id attribute" do
        result = Turn::Operation::Create.wtf?(params: {turn: {
            entry: valid_entry, 
            user_id: "hello", 
            game_id: 5678
        }})

        assert_equal false, result.success?
        assert_equal({:user_id=>["must be an integer"]}, result["result.contract.default"].errors.to_h)
    end

    it "Fails with no game_id attribute" do
        result = Turn::Operation::Create.wtf?(params: {turn: {
            entry: valid_entry, 
            user_id: 1234, 
            game_id: nil
        }})

        assert_equal false, result.success?
        assert_equal({:game_id=>["must be filled"]}, result["result.contract.default"].errors.to_h)
    end

    it "Fails with non-integer game_id attribute" do
        result = Turn::Operation::Create.wtf?(params: {turn: {
            entry: valid_entry, 
            user_id: 1234, 
            game_id: "hello"
        }})

        assert_equal false, result.success?
        assert_equal({:game_id=>["must be an integer"]}, result["result.contract.default"].errors.to_h)
    end
end