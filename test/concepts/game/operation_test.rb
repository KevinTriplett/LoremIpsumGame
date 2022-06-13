require 'test_helper'
require 'spec/spec_helper'

class GameOperationTest < MiniTest::Spec
  it "Creates {Game} model when given valid attributes" do
    result = Game::Operation::Create.wtf?(
      params: {game: {name: "lorem"}},
      errors: {}
    )

    assert_equal true, result.success?

    model = result[:game]
    assert_equal "lorem", model.name

    assert_equal({}, result["result.contract.default"].errors.to_h)
  end

  it "Fails with invalid parameters" do
    result = Game::Operation::Create.wtf?(params: {})

    assert_equal false, result.success?
    assert_nil(result["result.contract.default"])
  end

  it "Fails with invalid name attribute" do
    result = Game::Operation::Create.wtf?(params: {game: {name: ""}})

    assert_equal false, result.success?
    assert_equal({:name=>["must be filled"]}, result["result.contract.default"].errors.to_h)
  end
end