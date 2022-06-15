module User::Operation
  class Create < Trailblazer::Operation

    class Present < Trailblazer::Operation
      step Model(User, :new)
      step Contract::Build(constant: User::Contract::Create)
    end
    
    step Subprocess(Present)
    step Contract::Validate(key: :user)
    step Contract::Persist()
    step :initialize_game
    step :notify

    def initialize_game(ctx, **)
      user = ctx[:model]
      game = Game.find(user.game_id)
      game.current_player_id ||= user.id
      game.save
    end

    def notify(ctx, **)
      user = ctx[:model]
      UserMailer.with(params: user).welcome
    end
  end
end