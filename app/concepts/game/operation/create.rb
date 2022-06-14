class Game::Operation::Create < Trailblazer::Operation
    class Validations < Dry::Validation::Contract
        params do
            required(:name).filled
        end
    end

    step Contract::Validate(constant: Validations.new, key: :game)
    step :create_model

    def create_model(ctx, **)
        ctx[:game] = Game.new(**ctx["result.contract.default"].to_h)
        ctx[:game].save
    end
end