module User::Operation
  class Create < Trailblazer::Operation

    class Present < Trailblazer::Operation
      step Model(User, :new)
      step :initialize_game_id
      step Contract::Build(constant: User::Contract::Create)

      def initialize_game_id(ctx, model:, **)
        model.game_id = ctx[:game_id]
      end
    end
    
    step Subprocess(Present)
    step Contract::Validate(key: :user)
    step Contract::Persist()
    step :initialize_game
    step :notify

    def initialize_game(ctx, model:, **)
      game = Game.find(model.game_id)
      game.current_player_id ||= model.id
      game.save!
    end

    def notify(ctx, model:, **)
      UserMailer.welcome_email(model).deliver_now
    end
  end
end