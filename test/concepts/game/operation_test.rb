require 'test_helper'
require 'spec/spec_helper'

class GameOperationTest < MiniTest::Spec
    # ----------------
    # happy path tests
    it "Creates {Game} model when given valid attributes" do
    result = Game::Operation::Create.wtf?(params: {
      game: {
        name: random_game_name,
        game_days: 3,
        turn_hours: 2
      }
    })

    assert_equal true, result.success?
    assert_equal last_random_game_name, result[:model].name
    assert_equal 3, result[:model].game_days
    assert_equal 2, result[:model].turn_hours
  end

  it "Initializes {Game} model rules when no attributes provided" do
    result = Game::Operation::Create.wtf?(params: {
      game: {
        name: random_game_name
      }
    })

    assert_equal true, result.success?
    assert_equal last_random_game_name, result[:model].name
    assert_equal Rails.configuration.default_game_days, result[:model].game_days
    assert_equal Rails.configuration.default_turn_hours, result[:model].turn_hours
  end

  it "Updates game end when game_days rule changes" do
    start = Time.now
    game = create_game(game_days: 2, game_start: start, game_end: start + 2.days)
    game = Game.find(game.id)
    start = game.game_start

    result = Game::Operation::Update.wtf?(params: {
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

  it "Updates turn end when turn_hours rule changes" do
    start = Time.now
    game = create_game(turn_hours: 4, turn_start: start, turn_end: start + 4.hours)
    game = Game.find(game.id)
    start = game.turn_start

    result = Game::Operation::Update.wtf?(params: {
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

  # ----------------
  # failing tests
  it "Fails with invalid parameters" do
    result = Game::Operation::Create.wtf?(params: {})

    assert_equal false, result.success?
  end

  it "Fails with non-unique name" do
    Game::Operation::Create.wtf?(params: {
      game: {
        name: random_game_name
      }
    })

    result = Game::Operation::Create.wtf?(params: {
      game: {
        name: last_random_game_name
      }
    })

    assert_equal false, result.success?
  end

  it "Fails with invalid name attribute" do
    result = Game::Operation::Create.wtf?(params: {
      game: {
        name: ""
      }
    })

    assert_equal false, result.success?
    assert_equal(["name must be filled"], result["contract.default"].errors.full_messages_for(:name))
  end
end