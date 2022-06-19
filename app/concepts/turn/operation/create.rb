class Turn::Operation::Create < Trailblazer::Operation

    class Present < Trailblazer::Operation
      step Model(Turn, :new)
      step Contract::Build(constant: Turn::Contract::Create)
    end
    
    step Subprocess(Present)
    step Contract::Validate(key: :turn)
    step Contract::Persist()
    step :update_game
    step :notify

    def MyTransaction
    
    end

    def update_game(ctx, **)
      turn = ctx[:model]
      game = Game.find(turn.game_id)
      game.game_start ||= Time.now
      game.game_end ||= game.game_start + Rails.configuration.game_days.days
      game.turn_start = Time.now
      game.turn_end = game.turn_start + Rails.configuration.turn_hours.hours
      # set next player as current player
      game.current_player_id = User.next_user(turn.user_id, turn.game_id).id
      game.save
    end

    def notify(ctx, **)
      TurnMailer.with(turn: ctx[:model]).turn_notification
    end
end