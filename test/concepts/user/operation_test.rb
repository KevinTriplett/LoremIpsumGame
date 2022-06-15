require 'test_helper'
require 'spec/spec_helper'

class UserOperationTest < MiniTest::Spec
    it "Creates {User} model when given valid attributes" do
        game = Game.create(name: "game")

        result = User::Operation::Create.wtf?(params: {user: {
            name: "john smith", 
            email: "abc@xyz.com", 
            game_id: game.id
        }})

        assert_equal true, result.success?

        user = result[:model]
        assert_equal "john smith", user.name
        assert_equal "abc@xyz.com", user.email
    end

    it "Initializes game.current_player_id" do
        game = Game.create(name: "game")

        result = User::Operation::Create.wtf?(params: {user: {
            name: "john smith", 
            email: "abc@xyz.com", 
            game_id: game.id
        }})

        user = result[:model]
        game = Game.find(game.id)
        assert_equal user.id, game.current_player_id
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

    it "Fails with invalid parameters" do
        result = User::Operation::Create.wtf?(params: {})
    
        assert_equal false, result.success?
        assert_nil(result["result.contract.default"])
      end
        
    it "Fails with no name attribute" do
        game = Game.create(name: "game")

        result = User::Operation::Create.wtf?(params: {user: {
            name: "", 
            email: "abc@xyz.com", 
            game_id: game.id}
        })

        assert_equal false, result.success?
        # TODO: uncomment
        # assert_equal({:name=>["must be filled"]}, result["contract.default"].errors.to_h)
    end

    it "Fails with invalid email attribute" do
        game = Game.create(name: "game")

        result = User::Operation::Create.wtf?(params: {user: {
            name: "john smith", 
            email: "hello@splat", 
            game_id: game.id}
        })

        assert_equal false, result.success?
        # TODO: uncomment
        # assert_equal({:email=>["has invalid format"]}, result["contract.default"].errors.to_h)
    end

    it "Fails with no email attribute" do
        game = Game.create(name: "game")

        result = User::Operation::Create.wtf?(params: {user: {
            name: "john smith", 
            email: "", 
            game_id: game.id}
        })

        assert_equal false, result.success?
        # TODO: uncomment
        # assert_equal({:email=>["must be filled"]}, result["contract.default"].errors.to_h)
    end

    it "Fails with no game_id attribute" do
        game = Game.create(name: "game")

        result = User::Operation::Create.wtf?(params: {user: {
            name: "john smith", 
            email: "abc@xyz.com", 
            game_id: nil}
        })

        assert_equal false, result.success?
        # TODO: uncomment
        # assert_equal({:game_id=>["must be filled"]}, result["contract.default"].errors.to_h)
    end

    it "Fails with non-integer game_id attribute" do
        game = Game.create(name: "game")

        result = User::Operation::Create.wtf?(params: {user: {
            name: "john smith", 
            email: "abc@xyz.com", 
            game_id: "hello"}
        })

        assert_equal false, result.success?
        # TODO: uncomment
        # assert_equal({:game_id=>["must be an integer"]}, result["contract.default"].errors.to_h)
    end
end