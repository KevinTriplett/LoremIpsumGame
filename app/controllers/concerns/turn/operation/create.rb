class Turn::Operation::Create < Trailblazer::Operation
  class Validations < Dry::Validation::Contract
    params do
      required(:entry).filled
      required(:game_id).filled.value(:integer)
      required(:user_id).filled.value(:integer)
    end

    rule(:entry) do
      msg = "too short, must be more than " + Rails.configuration.entry_length_min.to_s + " letters"
      key.failure(msg) if value.length < Rails.configuration.entry_length_min
      msg = "too long, must be less than " + Rails.configuration.entry_length_max.to_s + " letters"
      key.failure(msg) if value.length > Rails.configuration.entry_length_max
    end
  end

  step Contract::Validate(constant: Validations.new, key: :turn)
  step :create_model
  step :update_game
  step :notify

  def create_model(ctx, **)
    ctx[:turn] = Turn.new(**ctx["result.contract.default"].to_h)
    ctx[:turn].save
  end

  def update_game(ctx, turn:, **)
    game = Game.find(turn.game_id)
    game.game_start ||= Time.now
    game.game_end ||= game.game_start + Rails.configuration.game_days.days
    game.turn_start = Time.now
    game.turn_end = game.turn_start + Rails.configuration.turn_hours.hours
    # set next player as current player
    game.current_player_id = User.next_user(turn.user_id, turn.game_id).id
    game.save
  end

  def notify(ctx, turn:, **)
    TurnMailer.with(turn: turn).turn_notification
  end
end