require 'test_helper'

class UserOperationTest < MiniTest::Spec
    it "Creates {User} model when given valid attributes" do
        game = Game.create(name: "game")

        result = User::Operation::Create.wtf?(params: {user: {
            name: "john smith", 
            email: "abc@xyz.com", 
            game_id: game.id
        }})

        assert_equal true, result.success?

        model = result[:user]
        assert_equal "john smith", model.name
        assert_equal "abc@xyz.com", model.email
    end

    it "Initializes game.current_player_id" do
        game = Game.create(name: "game")

        result = User::Operation::Create.wtf?(params: {user: {
            name: "john smith", 
            email: "abc@xyz.com", 
            game_id: game.id
        }})

        model = result[:user]
        game = Game.find(model.game_id)
        assert_equal model.id, game.current_player_id
    end

    it "Does not update initialized game.current_player_id" do
        game = Game.create(name: "game", current_player_id: "1234")

        result = User::Operation::Create.wtf?(params: {user: {
            name: "john smith", 
            email: "abc@xyz.com", 
            game_id: game.id}
        })

        assert_equal 1234, game.current_player_id
    end

    it "Fails with invalid name attribute" do
        game = Game.create(name: "game")

        result = User::Operation::Create.wtf?(params: {user: {
            name: "", 
            email: "abc@xyz.com", 
            game_id: game.id}
        })

        assert_equal false, result.success?
    end

    it "Fails with invalid email attribute" do
        game = Game.create(name: "game")

        result = User::Operation::Create.wtf?(params: {user: {
            name: "john smith", 
            email: "", 
            game_id: game.id}
        })

        assert_equal false, result.success?
    end

    it "Fails with invalid game_id attribute" do
        game = Game.create(name: "game")

        result = User::Operation::Create.wtf?(params: {user: {
            name: "john smith", 
            email: "abc@xyz.com", 
            game_id: nil}
        })

        assert_equal false, result.success?
    end
end