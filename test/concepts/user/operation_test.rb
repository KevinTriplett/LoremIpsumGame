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
        assert_equal 0, user.play_order
      end
    end

    it "Initializes game.current_player_id" do
      DatabaseCleaner.cleaning do
        game = create_game
        user = create_game_user(game_id: game.id)

        game.reload
        assert game.current_player_id
        assert_equal user.id, game.current_player_id
      end
    end

    it "Initializes play_order in order of user creation" do
      DatabaseCleaner.cleaning do
        game = create_game
        user1 = create_game_user(game_id: game.id)
        user2 = create_game_user(game_id: game.id)
        user3 = create_game_user(game_id: game.id)

        assert_equal 0, user1.play_order
        assert_equal 1, user2.play_order
        assert_equal 2, user3.play_order
      end
    end

    it "Does not update initialized game.current_player_id" do
      DatabaseCleaner.cleaning do
        game = create_game
        user1 = create_game_user(game_id: game.id)
        game.reload
        assert_equal user1.id, game.current_player_id

        user2 = create_game_user(game_id: game.id)
        game.reload
        assert_equal user1.id, game.current_player_id
      end
    end

    it "Allows non-unique email address for different games" do
      DatabaseCleaner.cleaning do
        game1 = create_game
        game2 = create_game
        user1 = create_game_user(game_id: game1.id)

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
        user = create_game_user(game_id: game.id)
        assert user.token
      end
    end

    it "Sends an email on user creation" do
      DatabaseCleaner.cleaning do
        ActionMailer::Base.deliveries.clear
        game = create_game
        user = create_game_user(game_id: game.id)

        assert_emails 2
        email = ActionMailer::Base.deliveries.first
        assert_equal email.subject, '[Lorem Ipsum] Welcome to the Game 🤗'
        assert_match /#{user.name}/, email.body.encoded

        email = ActionMailer::Base.deliveries.last
        assert_equal email.subject, "[Lorem Ipsum] Yay! It's Your Turn! 🥳"
        assert_match /#{user.name}/, email.body.encoded
        assert_match /#{get_magic_link(user)}/, email.body.encoded

        ActionMailer::Base.deliveries.clear
        user = create_game_user(game_id: game.id)

        assert_emails 1
        email = ActionMailer::Base.deliveries.last
        assert_equal email.subject, '[Lorem Ipsum] Welcome to the Game 🤗'
        assert_match /#{user.name}/, email.body.encoded
        ActionMailer::Base.deliveries.clear
      end
    end

    it "nils game.current_player_id and sends an email on user deletion" do
      DatabaseCleaner.cleaning do
        game = create_game
        user = create_game_user(game_id: game.id)

        ActionMailer::Base.deliveries.clear
        User::Operation::Delete.call({
          params: {
            id: user.id
          }
        })
        game.reload
        assert_nil game.current_player_id

        assert_emails 1
        email = ActionMailer::Base.deliveries.last
        assert_equal email.subject, '[Lorem Ipsum] Sorry to see you go 😭'
        assert_match /#{user.name}/, email.body.encoded
        ActionMailer::Base.deliveries.clear
      end
    end

    it "shuffles players on user deletion" do
      DatabaseCleaner.cleaning do
        game = create_game
        user1 = create_game_user(game_id: game.id)
        user2 = create_game_user(game_id: game.id)
        user3 = create_game_user(game_id: game.id)
        user4 = create_game_user(game_id: game.id)
        game.reload
        assert_equal [0,1,2,3], game.users.order(id: :asc).pluck(:play_order)

        User::Operation::Delete.call({
          params: {
            id: user2.id
          }
        })
        game.reload
        assert_equal [1,0,2], game.users.order(id: :asc).pluck(:play_order)
      end
    end

    it "Doesn't shuffle players when adding user" do
      DatabaseCleaner.cleaning do
        game = create_game
        user1 = create_game_user(game_id: game.id)
        user2 = create_game_user(game_id: game.id)
        user3 = create_game_user(game_id: game.id)
        user4 = create_game_user(game_id: game.id)
        game.reload
        assert_equal [0,1,2,3], game.users.order(id: :asc).pluck(:play_order)

        user4 = create_game_user(game_id: game.id)
        game.reload
        assert_equal [0,1,2,3,4], game.users.order(id: :asc).pluck(:play_order)
      end
    end

    it "Doesn't disturb game attributes when adding user" do
      DatabaseCleaner.cleaning do
        start = Time.now
        game = create_game(turn_hours: 4, turn_start: start, turn_end: start + 4.hours, num_rounds: 3, round: 2)
        game.reload
        user = create_game_user(game_id: game.id)
        assert_equal game.turn_hours, user.game.turn_hours
        assert_equal game.turn_start, user.game.turn_start
        assert_equal game.turn_end, user.game.turn_end
        assert_equal game.num_rounds, user.game.num_rounds
        assert_equal game.round, user.game.round
      end
    end

    it "Reassigns current_player_id and sends turn notification email on current user deletion" do
      DatabaseCleaner.cleaning do
        game = create_game
        user1 = create_game_user(game_id: game.id)
        user2 = create_game_user(game_id: game.id)
        game.reload
        assert_equal user1.id, game.current_player_id

        ActionMailer::Base.deliveries.clear
        User::Operation::Delete.call({
          params: {
            id: user1.id
          }
        })
        game.reload
        assert_equal user2.id, game.current_player_id

        assert_emails 2
        email = ActionMailer::Base.deliveries.first
        assert_equal email.subject, "[Lorem Ipsum] Yay! It's Your Turn! 🥳"
        assert_match /#{user2.name}/, email.body.encoded

        email = ActionMailer::Base.deliveries.last
        assert_equal email.subject, "[Lorem Ipsum] Sorry to see you go 😭"
        assert_match /#{user1.name}/, email.body.encoded
        ActionMailer::Base.deliveries.clear
      end
    end

    it "Update allows non-unique email address for same user" do
      DatabaseCleaner.cleaning do
        game = create_game
        user = create_game_user(game_id: game.id)
        
        result = User::Operation::Update.call(
          params: {
            user: {
              id: user.id,
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
              email: random_email
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
              email: random_email
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
        user = create_game_user(game_id: game.id)

        result = User::Operation::Create.call(
          params: {
            user: {
              name: random_user_name, 
              email: user.email
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