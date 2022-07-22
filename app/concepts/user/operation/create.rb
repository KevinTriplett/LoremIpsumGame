module User::Operation
  class Create < Trailblazer::Operation

    class Present < Trailblazer::Operation
      step Model(User, :new)
      step :initialize_game_id
      step Contract::Build(constant: User::Contract::Create)

      def initialize_game_id(ctx, **)
        ctx[:model].game_id = ctx[:game_id]
      end
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
      UserMailer.with(user: user).welcome_email.deliver_now
    end
  end
end