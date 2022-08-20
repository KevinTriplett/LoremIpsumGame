module User::Operation
  class Delete < Trailblazer::Operation
    step Model(User, :find_by)
    step :update_game
    step :delete
    step :notify

    def update_game(ctx, model:, **)
      game = model.game
      game.shuffle_players
      # deleting current player ?
      return true unless game.current_player_id == model.id
      # deleting last player ?
      next_player_id = (game.users.count == 1 ? nil : game.next_player_id)
      game.update(current_player_id: next_player_id)
      return true unless next_player_id
      user = User.find(next_player_id)
      UserMailer.with(user: user).turn_notification.deliver_now
    end

    def delete(ctx, model:, **)
      model.destroy
    end

    def notify(ctx, model:, **)
      UserMailer.with(user: model).goodbye_email.deliver_now
    end
  end
end