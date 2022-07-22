require 'test_helper'
require 'spec/spec_helper'

class UserOperationTest < MiniTest::Spec
    # ----------------
    # happy path tests
    it "Creates {User} model when given valid attributes" do
        game = create_game

        result = User::Operation::Create.wtf?(params: {
            user: {
                name: "john smith", 
                email: random_email
            }},
            game_id: game.id
        )

        assert_equal true, result.success?
        user = result[:model]
        assert_equal "john smith", user.name
        assert_equal last_random_email, user.email
    end

    it "Initializes game.current_player_id" do
        game = create_game

        result = User::Operation::Create.wtf?(params: {
            user: {
                name: "john smith", 
                email: random_email
            }},
            game_id: game.id
        )

        assert_equal true, result.success?
        user = result[:model]
        game = Game.find(game.id)
        assert user.id
        assert_equal user.id, game.current_player_id
    end

    it "Does not update initialized game.current_player_id" do
        game = Game.create(name: random_game_name, current_player_id: "1234")

        result = User::Operation::Create.wtf?(params: {
            user: {
                name: "john smith", 
                email: random_email
            }},
            game_id: game.id
        )

        assert_equal true, result.success?
        assert_equal 1234, game.current_player_id
    end

    it "Allows non-unique email address for different games" do
        game1 = create_game
        game2 = create_game
        User::Operation::Create.wtf?(params: {
            user: {
                name: "john smith", 
                email: random_email
            }},
            game_id: game1.id
        )

        result = User::Operation::Create.wtf?(params: {
            user: {
                name: "jane doe", 
                email: last_random_email
            }},
            game_id: game2.id
        )

        puts "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx game1, game2 = " + game1.id.to_s + "  " + game2.id.to_s
        assert_equal true, result.success?
    end

    # TODO: create validation for this one
    # it "Allows non-unique email address for same user" do
    #     game = create_game
    #     result = User::Operation::Create.wtf?(params: {
    #         user: {
    #             name: "john smith", 
    #             email: random_email
    #         },
    #         game_id: game.id
    #    })
    #     user = result["contract.default"].model
    #     # assert_equal true, result.success?

    #     result = User::Operation::Update.wtf?(params: {
    #    user: {
    #             id: user.id,
    #             name: "johnny smith"
    #             email: last_random_email,
    #         },
    #         game_id: game.id
    #     })

    #     assert_equal true, result.success?
    # end

    # ----------------
    # failing tests
    it "Fails with invalid parameters" do
        result = User::Operation::Create.wtf?(params: {})
    
        assert_equal false, result.success?
      end
        
    it "Fails with no name attribute" do
        game = create_game

        result = User::Operation::Create.wtf?(params: {
            user: {
                name: "", 
                email: "abc@xyz.com"
            }},
            game_id: game.id
        )

        assert_equal false, result.success?
        assert_equal(["name must be filled"], result["contract.default"].errors.full_messages_for(:name))
    end

    it "Fails with invalid email attribute" do
        game = create_game

        result = User::Operation::Create.wtf?(params: {
            user: {
                name: "john smith", 
                email: "hello@splat"
            }},
            game_id: game.id
        )

        assert_equal false, result.success?
        assert_equal(["email has invalid format"], result["contract.default"].errors.full_messages_for(:email))
    end

    it "Fails with no email attribute" do
        game = create_game

        result = User::Operation::Create.wtf?(params: {
            user: {
                name: "john smith", 
                email: ""
            }},
            game_id: game.id
        )

        assert_equal false, result.success?
        assert_equal(["email must be filled"], result["contract.default"].errors.full_messages_for(:email))
    end

    it "Fails with no game_id attribute" do
        game = create_game

        result = User::Operation::Create.wtf?(params: {
            user: {
                name: "john smith", 
                email: "abc@xyz.com"
            }},
            game_id: nil
        )

        assert_equal false, result.success?
    end

    it "Fails with non-unique email address on same game" do
        game = create_game
        User::Operation::Create.wtf?(params: {
            user: {
                name: "john smith", 
                email: random_email
            }},
            game_id: game.id
        )

        result = User::Operation::Create.wtf?(params: {
            user: {
                name: "jane doe", 
                email: last_random_email
            }},
            game_id: game.id
        )

        assert_equal false, result.success?
        assert_equal(["email must be unique"], result["contract.default"].errors.full_messages_for(:email))
    end
end