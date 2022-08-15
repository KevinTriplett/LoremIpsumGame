module User::Operation
  class Create < Trailblazer::Operation

    class Present < Trailblazer::Operation
      step Model(User, :new)
      step :initialize_attributes
      step Contract::Build(constant: User::Contract::Create)

      def initialize_attributes(ctx, model:, **)
        return false unless ctx[:game_id]
        game = Game.find(ctx[:game_id])
        model.game_id = game.id
        model.play_order = game.users.count
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
      UserMailer.with(user: model).welcome_email.deliver_now
    end
  end
end