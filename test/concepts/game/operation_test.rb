require 'test_helper'
require 'spec/spec_helper'

class GameOperationTest < MiniTest::Spec
    # ----------------
    # happy path tests
    it "Creates {Game} model when given valid attributes" do
    result = Game::Operation::Create.wtf?(params: {game: {
      name: random_game_name,
      game_days: 3,
      turn_hours: 2
    }})

    assert_equal true, result.success?
    assert_equal last_random_game_name, result[:model].name
    assert_equal 3, result[:model].game_days
    assert_equal 2, result[:model].turn_hours
  end

  it "Initializes {Game} model rules when no attributes provided" do
    result = Game::Operation::Create.wtf?(params: {game: {
      name: random_game_name
    }})

    assert_equal true, result.success?
    assert_equal last_random_game_name, result[:model].name
    assert_equal Rails.configuration.default_game_days, result[:model].game_days
    assert_equal Rails.configuration.default_turn_hours, result[:model].turn_hours
  end

  # ----------------
  # failing tests
  it "Fails with invalid parameters" do
    result = Game::Operation::Create.wtf?(params: {})

    assert_equal false, result.success?
  end

  it "Fails with non-unique name" do
    Game::Operation::Create.wtf?(params: {game: {
      name: random_game_name
    }})

    result = Game::Operation::Create.wtf?(params: {game: {
      name: last_random_game_name
    }})

    assert_equal false, result.success?
  end

  it "Fails with invalid name attribute" do
    result = Game::Operation::Create.wtf?(params: {game: {
      name: ""
    }})

    assert_equal false, result.success?
    assert_equal(["name must be filled"], result["contract.default"].errors.full_messages_for(:name))
  end
end