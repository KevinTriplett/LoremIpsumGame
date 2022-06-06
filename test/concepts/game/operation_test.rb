require 'test_helper'
require 'spec/spec_helper'

class GameOperationTest < MiniTest::Spec
    it "Creates {Game} model when given valid attributes" do
        result = Game::Operation::Create.wtf?(params: {game: {name: "lorem"}})

        assert_equal true, result.success?

        model = result[:game]
        assert_equal "lorem", model.name
    end

    it "Fails with invalid name attribute" do
        result = Game::Operation::Create.wtf?(params: {game: {name: ""}})

        assert_equal false, result.success?
    end
end