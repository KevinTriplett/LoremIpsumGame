class User::Operation::Create < Trailblazer::Operation
    step :extract_params
    step :validate_for_create?
    step :create_model
    step :initialize_game
    step :notify

    def extract_params(ctx, params:, **)
        ctx[:my_params] = params[:user]
    end

    def validate_for_create?(ctx, my_params:, **)
        my_params[:name].present? && 
        my_params[:email].present? && 
        my_params[:game_id].present?
    end

    def create_model(ctx, my_params:, **)
        ctx[:user] = User.new(**my_params)
        ctx[:user].save
    end

    def initialize_game(ctx, user:, **)
        game = Game.find(user.game_id)
        game.current_player_id ||= user.id
        game.save
    end

    def notify(ctx, user:, **)
        UserMailer.with(params: user).welcome
    end
end