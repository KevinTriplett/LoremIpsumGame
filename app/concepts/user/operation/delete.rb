module User::Operation
  class Delete < Trailblazer::Operation
    step Model(User, :find_by)
    step :update_game
    step :delete
    step :notify

    def update_game(ctx, model:, **)
      game = model.game
      # deleting current player ?
      return true unless game.current_player_id == model.id
      # deleting last player ?
      next_player_id = (game.users.count == 1 ? nil : game.next_player_id)
      game.update(current_player_id: next_player_id)
      return true unless next_player_id
      user = User.find(next_player_id)
      UserMailer.turn_notification(user).deliver_now
    end

    def delete(ctx, model:, **)
      model.destroy
    end

    def notify(ctx, model:, **)
      UserMailer.goodbye_email(model).deliver_now
    end
  end
end