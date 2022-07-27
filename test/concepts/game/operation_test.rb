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
            game_days: 3,
            turn_hours: 2
          }
        })
        pad_name = last_random_game_name.gsub(/\s/, '_')

        assert_equal true, result.success?
        assert_equal last_random_game_name, result[:model].name
        assert_equal pad_name, result[:model].pad_name
        assert_equal 3, result[:model].game_days
        assert_equal 2, result[:model].turn_hours
      end
    end

    it "Initializes {Game} model rules when no attributes provided" do
      DatabaseCleaner.cleaning do
        result = Game::Operation::Create.call(params: {
          game: {
            name: random_game_name
          }
        })

        assert_equal true, result.success?
        assert_equal last_random_game_name, result[:model].name
        assert_equal Rails.configuration.default_game_days, result[:model].game_days
        assert_equal Rails.configuration.default_turn_hours, result[:model].turn_hours
      end
    end

    it "does not change pad_name when game name changes" do
      DatabaseCleaner.cleaning do
        start = Time.now
        game = create_game(game_days: 2, game_start: start, game_end: start + 2.days)
        game = Game.find(game.id)
        start = game.game_start
        old_pad_name = game.pad_name

        result = Game::Operation::Update.call(params: {
          game: {
            id: game.id,
            name: random_game_name,
            game_days: game.game_days,
            turn_hours: game.turn_hours
          },
          id: game.id
        })

        game = Game.find(game.id)
        assert_equal old_pad_name, game.pad_name
        assert_equal last_random_game_name, game.name
      end
    end

    it "Updates game end when game_days rule changes" do
      DatabaseCleaner.cleaning do
        start = Time.now
        game = create_game(game_days: 2, game_start: start, game_end: start + 2.days)
        game = Game.find(game.id)
        start = game.game_start

        result = Game::Operation::Update.call(params: {
          game: {
            id: game.id,
            name: game.name,
            game_days: 4,
            turn_hours: game.turn_hours
          },
          id: game.id
        })

        game = Game.find(game.id)
        assert_equal (start + 4.days), game.game_end
      end
    end

    it "Updates turn end when turn_hours rule changes" do
      DatabaseCleaner.cleaning do
        start = Time.now
        game = create_game(turn_hours: 4, turn_start: start, turn_end: start + 4.hours)
        game = Game.find(game.id)
        start = game.turn_start

        result = Game::Operation::Update.call(params: {
          game: {
            id: game.id,
            name: game.name,
            game_days: game.game_days,
            turn_hours: 2
          },
          id: game.id
        })

        game = Game.find(game.id)
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

    it "Fails with non-unique name" do
      DatabaseCleaner.cleaning do
        Game::Operation::Create.call(params: {
          game: {
            name: random_game_name
          }
        })

        result = Game::Operation::Create.call(params: {
          game: {
            name: last_random_game_name
          }
        })

        assert_equal false, result.success?
      end
    end

    it "Fails with invalid name attribute" do
      DatabaseCleaner.cleaning do
        result = Game::Operation::Create.call(params: {
          game: {
            name: ""
          }
        })

        assert_equal false, result.success?
        assert_equal(["name must be filled"], result["contract.default"].errors.full_messages_for(:name))
      end
    end
  end
end