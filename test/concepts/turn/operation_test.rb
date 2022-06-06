require 'test_helper'

class TurnOperationTest < MiniTest::Spec
    it "Creates {Turn} model when given valid attributes" do
        game = Game.create(name: "game")
        user = User.create(name: "John John", email: "abc@xyz.com", game_id: game.id)

        entry = ""
        (Rails.configuration.entry_length_max).times { entry =+ "x" }
        result = Turn::Operation::Create.wtf?(params: {turn: {
            entry: entry, 
            user_id: user.id, 
            game_id: game.id
        }})

        assert_equal true, result.success?

        model = result[:turn]
        assert_equal entry, model.entry
        assert_equal user.id, model.user_id
        assert_equal game.id, model.game_id
    end

    it "Updates current_player_id attribute on last game model (no rollover)" do
        game = Game.create(name: "game")
        user1 = User.create(name: "John John", email: "abc@xyz.com", game_id: game.id)
        user2 = User.create(name: "Jill Jill", email: "cba@xyz.com", game_id: game.id)
        user3 = User.create(name: "Jack Jack", email: "dbd@xyz.com", game_id: game.id)

        result = Turn::Operation::Create.wtf?(params: {turn: {
            entry: "entry", 
            user_id: user2.id, 
            game_id: game.id
        }})

        game = Game.last
        assert_equal "game", game.name
        assert_equal user3.id, game.current_player_id
    end

    it "Updates current_player_id attribute on last game model (rollover)" do
        game = Game.create(name: "game")
        user1 = User.create(name: "John John", email: "abc@xyz.com", game_id: game.id)
        user2 = User.create(name: "Jill Jill", email: "cba@xyz.com", game_id: game.id)
        user3 = User.create(name: "Jack Jack", email: "dbd@xyz.com", game_id: game.id)
        
        result = Turn::Operation::Create.wtf?(params: {turn: {
            entry: "entry", 
            user_id: user3.id, 
            game_id: game.id
        }})

        game = Game.last
        assert_equal user1.id, game.current_player_id
    end

    it "Initializes game start/end datetime attributes" do
        game = Game.create(name: "game")
        user1 = User.create(name: "John John", email: "abc@xyz.com", game_id: game.id)
        user2 = User.create(name: "Jill Jill", email: "cba@xyz.com", game_id: game.id)

        result = Turn::Operation::Create.wtf?(params: {turn: {
            entry: "entry", 
            user_id: user1.id, 
            game_id: game.id
        }})

        game = Game.last
        assert_equal true, game.game_start.present?
        assert_equal true, game.game_end.present?
        assert_equal game.game_end, game.game_start + Rails.configuration.game_days.days
    end

    it "Does not change game start/end datetime attributes" do
        time_start, time_end = Time.now, Time.now + Rails.configuration.game_days.days
        game = Game.create(name: "game", game_start: time_start, game_end: time_end)
        user = User.create(name: "John John", email: "abc@xyz.com", game_id: game.id)

        result = Turn::Operation::Create.wtf?(params: {turn: {
            entry: "entry", 
            user_id: user.id, 
            game_id: game.id
        }})

        game = Game.last
        assert_equal time_start, game.game_start
        assert_equal time_end, game.game_end
    end

    it "Updates turn start/end datetime attributes" do
        game = Game.create(name: "game")
        user = User.create(name: "John John", email: "abc@xyz.com", game_id: game.id)
        
        result = Turn::Operation::Create.wtf?(params: {turn: {
            entry: "entry", 
            user_id: user.id, 
            game_id: game.id
        }})

        game = Game.last
        assert_equal true, game.turn_start.present?
        assert_equal true, game.turn_end.present?
        assert_equal game.turn_end, game.turn_start + Rails.configuration.turn_hours.hours
    end

    it "Fails with invalid entry attribute" do
        result = Turn::Operation::Create.wtf?(params: {turn: {
            entry: "", 
            user_id: 1234, 
            game_id: 5678
        }})

        assert_equal false, result.success?
    end

    it "Fails when entry is too long" do
        entry = ""
        (Rails.configuration.entry_length_max + 1).times { entry =+ "x" }
        result = Turn::Operation::Create.wtf?(params: {turn: {
            entry: "entry", 
            user_id: 1234, 
            game_id: 5678
        }})

        assert_equal false, result.success?
    end

    it "Fails with invalid user_id attribute" do
        result = Turn::Operation::Create.wtf?(params: {turn: {
            entry: "entry", 
            user_id: nil, 
            game_id: 5678
        }})

        assert_equal false, result.success?
    end

    it "Fails with invalid game_id attribute" do
        result = Turn::Operation::Create.wtf?(params: {turn: {
            entry: "entry", 
            user_id: 1234, 
            game_id: nil
        }})

        assert_equal false, result.success?
    end
end