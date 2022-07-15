require 'test_helper'
require 'spec/spec_helper'

class GameOperationTest < MiniTest::Spec
    # ----------------
    # happy path tests
    it "Creates {Game} model when given valid attributes" do
    result = Game::Operation::Create.wtf?(params: {game: {
      name: random_game_name
    }})

    assert_equal true, result.success?
    assert_equal last_random_game_name, result[:model].name
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