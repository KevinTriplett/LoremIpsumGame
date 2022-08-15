module User::Operation
  class Delete < Trailblazer::Operation
    step Model(User, :find_by)
    step :update_game
    step :delete
    step :notify

    def update_game(ctx, model:, **)
      game = model.game
      if game.current_player_id == model.id
        # check for last player assigned to game being deleted
        if game.current_player_id
          game.current_player_id = (game.users.count == 1 ? nil : game.next_player_id)
          game.save
        end
      end
      true
    end

    def delete(ctx, model:, **)
      model.destroy
    end

    def notify(ctx, model:, **)
      UserMailer.goodbye_email(model).deliver_now
    end
  end
end