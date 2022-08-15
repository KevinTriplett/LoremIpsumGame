require 'test_helper'
require 'spec/spec_helper'

class GameOperationTest < MiniTest::Spec

  describe "GameOperation" do
    DatabaseCleaner.clean

    # ----------------
    # happy path tests
    it "Creates {Game} model when given valid attributes" do
      DatabaseCleaner.cleaning do
        result = Game::Operation::Create.call(params: {
          game: {
            name: random_game_name,
            num_rounds: 3,
            turn_hours: 2
          }
        })

        assert_equal true, result.success?
        game = result[:model]
        game.reload
        
        assert game.current_player_id.nil?
        assert_equal last_random_game_name, game.name
        assert_equal 3, game.num_rounds
        assert_equal 2, game.turn_hours
        assert_equal 1, game.round
        assert !game.game_ended?
      end
    end

    it "Updates turn end when turn_hours rule changes" do
      DatabaseCleaner.cleaning do
        start = Time.now
        game = create_game(turn_hours: 4, turn_start: start, turn_end: start + 4.hours)
        game.reload
        start = game.turn_start

        Game::Operation::Update.call(params: {
          game: {
            id: game.id,
            name: game.name,
            num_rounds: game.num_rounds,
            turn_hours: 2
          },
          id: game.id
        })

        game.reload
        assert_equal (start + 2.hours), game.turn_end
      end
    end

    # ----------------
    # failing tests
    it "Fails with invalid parameters" do
      DatabaseCleaner.cleaning do
        result = Game::Operation::Create.call(params: {})

        assert_equal false, result.success?
      end
    end

    it "Fails with missing turn_hours" do
      DatabaseCleaner.cleaning do
        result = Game::Operation::Create.call(params: {
          game: {
            name: random_game_name,
            num_rounds: 30
          }
        })

        assert_equal false, result.success?
        assert_equal(["turn_hours must be filled"], result["contract.default"].errors.full_messages_for(:turn_hours))
      end
    end

    it "Fails with missing num_rounds" do
      DatabaseCleaner.cleaning do
        result = Game::Operation::Create.call(params: {
          game: {
            name: random_game_name,
            turn_hours: 48
          }
        })

        assert_equal false, result.success?
        assert_equal(["num_rounds must be filled"], result["contract.default"].errors.full_messages_for(:num_rounds))
      end
    end

    it "Fails with non-unique name" do
      DatabaseCleaner.cleaning do
        result = Game::Operation::Create.call(params: {
          game: {
            name: random_game_name,
            num_rounds: 30,
            turn_hours: 48
          }
        })
        game = result[:model]

        result = Game::Operation::Create.call(params: {
          game: {
            name: last_random_game_name,
            num_rounds: game.num_rounds,
            turn_hours: game.turn_hours
          }
        })

        assert_equal false, result.success?
        assert_equal(["name must be unique"], result["contract.default"].errors.full_messages_for(:name))
      end
    end

    it "Fails with invalid name attribute" do
      DatabaseCleaner.cleaning do
        result = Game::Operation::Create.call(params: {
          game: {
            name: "",
            num_rounds: 20,
            turn_hours: 24
          }
        })

        assert_equal false, result.success?
        assert_equal(["name must be filled"], result["contract.default"].errors.full_messages_for(:name))
      end
    end
  end
end