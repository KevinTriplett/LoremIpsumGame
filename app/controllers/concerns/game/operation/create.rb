class Game::Operation::Create < Trailblazer::Operation
    step :extract_params
    step :validate_for_create?
    step :create_model
    step :save

    def extract_params(ctx, params:, **)
        ctx[:my_params] = params[:game]
    end

    def validate_for_create?(ctx, my_params:, **)
        my_params[:name].present?
    end

    def create_model(ctx, my_params:, **)
        ctx[:game] = Game.new(**my_params)
    end

    def save(ctx, **)
        ctx[:game].save
    end
end