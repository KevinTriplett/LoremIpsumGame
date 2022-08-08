require 'test_helper'
require 'spec/spec_helper'

class UserOperationTest < MiniTest::Spec
  include ActionMailer::TestHelper

  describe "TurnOperation" do
    DatabaseCleaner.clean

    # ----------------
    # happy path tests
    it "Creates {User} model when given valid attributes" do
      DatabaseCleaner.cleaning do
        game = create_game

        result = User::Operation::Create.call(
          params: {
            user: {
              name: random_user_name, 
              email: random_email
            }
          },
          game_id: game.id
        )

        assert_equal true, result.success?
        user = result[:model]
        assert_equal last_random_user_name, user.name
        assert_equal last_random_email, user.email
      end
    end

    it "Initializes game.current_player_id" do
      DatabaseCleaner.cleaning do
        game = create_game

        result = User::Operation::Create.call(
          params: {
            user: {
              name: random_user_name, 
              email: random_email
            }
          },
          game_id: game.id
        )

        assert_equal true, result.success?
        user = result[:model]
        game.reload
        assert user.id
        assert_equal user.id, game.current_player_id
      end
    end

    it "Does not update initialized game.current_player_id" do
      DatabaseCleaner.cleaning do
        game = create_game(name: random_game_name, current_player_id: "1234")

        result = User::Operation::Create.call(
          params: {
            user: {
              name: random_user_name, 
              email: random_email
            }
          },
          game_id: game.id
        )

        assert_equal true, result.success?
        assert_equal 1234, game.current_player_id
      end
    end

    it "Allows non-unique email address for different games" do
      DatabaseCleaner.cleaning do
        game1 = create_game
        game2 = create_game
        User::Operation::Create.call(
          params: {
            user: {
              name: random_user_name, 
              email: random_email
            }
          },
          game_id: game1.id
        )

        result = User::Operation::Create.call(
          params: {
            user: {
              name: "jane doe", 
              email: last_random_email
            }
          },
          game_id: game2.id
        )

        assert_equal true, result.success?
      end
    end

    it "Creates {User} model token when given valid attributes" do
      DatabaseCleaner.cleaning do
        game = create_game
        user = create_game_user(game.id)
        assert user.token
      end
    end

    it "Sends an email on user creation" do
      DatabaseCleaner.cleaning do
        ActionMailer::Base.deliveries.clear
        game = create_game

        User::Operation::Create.call(
          params: {
            user: {
              name: random_user_name, 
              email: random_email
            }
          },
          game_id: game.id
        )

        assert_emails 1
        ActionMailer::Base.deliveries.clear
      end
    end

    it "reassigns current_player_id to next player when user is deleted" do
      DatabaseCleaner.cleaning do
        game = create_game
        user1 = create_game_user(game.id)
        user2 = create_game_user(game.id)
        game.reload
        assert_equal user1.id, game.current_player_id

        User::Operation::Delete.call(
          params: {
            game_id: game.id,
            id: user1.id
          }
        )
        game.reload
        assert_equal user2.id, game.current_player_id
      end
    end

    it "nils game.current_player_id when all users deleted" do
      DatabaseCleaner.cleaning do
        game = create_game
        user = create_game_user(game.id)

        User::Operation::Delete.call(
          params: {
            game_id: game.id,
            id: user.id
          }
        )
        game.reload
        assert_nil game.current_player_id
      end
    end

    # TODO: create validation for this one
    it "Allows non-unique email address for same user" do
      DatabaseCleaner.cleaning do
        game = create_game
        result = User::Operation::Create.call(
          params: {
            user: {
              name: random_user_name, 
              email: random_email
            }
          },
          game_id: game.id
        )
        assert_equal true, result.success?
        user = result[:model]
        
        result = User::Operation::Update.call(
          params: {
            user: {
              id: "#{user.id}",
              name: "jumpin jack flash yeah",
              email: user.email
            },
            id: user.id
          }
        )
      
        assert_equal true, result.success?
      end
    end

    # ----------------
    # failing tests
    it "Fails with invalid parameters" do
      DatabaseCleaner.cleaning do
        result = User::Operation::Create.call(params: {})

        assert_equal false, result.success?
      end
    end

    it "Fails with no name attribute" do
      DatabaseCleaner.cleaning do
        game = create_game

        result = User::Operation::Create.call(
          params: {
            user: {
              name: "", 
              email: "abc@xyz.com"
            }
          },
          game_id: game.id
        )

        assert_equal false, result.success?
        assert_equal(["name must be filled"], result["contract.default"].errors.full_messages_for(:name))
      end
    end

    it "Fails with invalid email attribute" do
      DatabaseCleaner.cleaning do
        game = create_game

        result = User::Operation::Create.call(
          params: {
            user: {
              name: random_user_name, 
              email: "hello@splat"
            }
          },
          game_id: game.id
        )

        assert_equal false, result.success?
        assert_equal(["email has invalid format"], result["contract.default"].errors.full_messages_for(:email))
      end
    end

    it "Fails with no email attribute" do
      DatabaseCleaner.cleaning do
        game = create_game

        result = User::Operation::Create.call(
          params: {
            user: {
              name: random_user_name, 
              email: ""
            }
          },
          game_id: game.id
        )

        assert_equal false, result.success?
        assert_equal(["email must be filled"], result["contract.default"].errors.full_messages_for(:email))
      end
    end

    it "Fails with no game_id attribute" do
      DatabaseCleaner.cleaning do
        game = create_game

        result = User::Operation::Create.call(
          params: {
            user: {
              name: random_user_name, 
              email: "abc@xyz.com"
            }
          },
          game_id: nil
        )

        assert_equal false, result.success?
      end
    end

    it "Fails with non-unique email address on same game" do
      DatabaseCleaner.cleaning do
        game = create_game
        User::Operation::Create.call(
          params: {
            user: {
              name: random_user_name, 
              email: random_email
            }
          },
          game_id: game.id
        )

        result = User::Operation::Create.call(
          params: {
            user: {
              name: "jane doe", 
              email: last_random_email
            }
          },
          game_id: game.id
        )

        assert_equal false, result.success?
        assert_equal(["email must be unique"], result["contract.default"].errors.full_messages_for(:email))
      end
    end
  end
end