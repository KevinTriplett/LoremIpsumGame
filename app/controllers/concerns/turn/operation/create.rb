class Turn::Operation::Create < Trailblazer::Operation
    step :extract_params
    step :validate_for_create?
    step :create_model
    step :save
    step :update_game
    step :notify

    def extract_params(ctx, params:, **)
        ctx[:my_params] = params[:turn]
    end

    def validate_for_create?(ctx, my_params:, **)
        my_params[:entry].present? && 
        my_params[:entry].length < Rails.configuration.entry_length_max && 
        my_params[:user_id].present? &&
        my_params[:game_id].present?
    end

    def create_model(ctx, my_params:, **)
        ctx[:turn] = Turn.new(**my_params)
    end

    def save(ctx, **)
        ctx[:turn].save
    end

    def update_game(ctx, my_params:, turn:, **)
        game = Game.find(turn.game_id)
        game.game_start ||= Time.now
        game.game_end ||= game.game_start + Rails.configuration.game_days.days
        game.turn_start = Time.now
        game.turn_end = game.turn_start + Rails.configuration.turn_hours.hours
        game.current_player_id = User.next_user(my_params[:user_id], my_params[:game_id]).id
        game.save
    end

    def notify(ctx, turn:, **)
        TurnMailer.with(turn: turn).turn_notification
    end
end