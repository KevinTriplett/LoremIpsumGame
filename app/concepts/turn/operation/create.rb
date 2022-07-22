class Turn::Operation::Create < Trailblazer::Operation

  class Present < Trailblazer::Operation
    step Model(Turn, :new)
    step :initialize_user
    step Contract::Build(constant: Turn::Contract::Create)

    def initialize_user(ctx, **)
      ctx[:model].user_id = ctx[:user_id]
    end
  end
  
  step Subprocess(Present)
  step Contract::Validate(key: :turn)
  step Contract::Persist()
  step :update_game
  step :notify

  def update_game(ctx, **)
    turn = ctx[:model]
    user = User.find(turn.user_id)
    game = user.game
    game.game_start ||= Time.now
    game.game_end ||= game.game_start + Rails.configuration.game_days.days
    game.turn_start = Time.now
    game.turn_end = game.turn_start + Rails.configuration.turn_hours.hours
    # set next player as current player
    game.current_player_id = User.next_user(user.id, user.game_id).id
    game.save
  end

  def notify(ctx, **)
    TurnMailer.with(turn: ctx[:model]).turn_notification
  end
end