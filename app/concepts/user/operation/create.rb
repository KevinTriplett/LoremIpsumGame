module User::Operation
  class Create < Trailblazer::Operation

    class Present < Trailblazer::Operation
      step Model(User, :new)
      step :initialize_attributes
      step Contract::Build(constant: User::Contract::Create)

      def initialize_attributes(ctx, model:, **)
        model.game_id = ctx[:game_id]
      end
    end
    
    step Subprocess(Present)
    step Contract::Validate(key: :user)
    step Contract::Persist()
    step :update_game
    step :notify

    def update_game(ctx, model:, **)
      game = Game.find(model.game_id)
      return true if game.current_player_id
      game.update(current_player_id: model.id)
    end

    def notify(ctx, model:, **)
      UserMailer.welcome_email(model).deliver_now
    end
  end
end