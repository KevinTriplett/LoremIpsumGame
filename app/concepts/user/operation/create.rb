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
        i = game.users.count
        model.play_order = i
        model.author_color = User.pick_author_color(i)
      end
    end
    
    step Subprocess(Present)
    step Contract::Validate(key: :user)
    step Contract::Persist()
    step :notify
    step :update_game

    def notify(ctx, model:, **)
      UserMailer.with(user: model).welcome_email.deliver_now
    end

    def update_game(ctx, model:, **)
      game = Game.find(model.game_id)
      return true if game.current_player_id
      game.update(current_player_id: model.id)
      UserMailer.with(user: model).turn_notification.deliver_now
    end
  end
end