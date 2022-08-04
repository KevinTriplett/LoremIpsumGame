module User::Operation
  class Delete < Trailblazer::Operation
    step Model(User, :find_by)
    step :update_game
    step :delete

    def update_game(ctx, model:, **)
      game = model.game
      if game.current_player_id == model.id
        next_player = User.next_player(model.id)
        # check for last player assigned to game being deleted
        game.current_player_id = next_player.id == model.id ? nil : next_player.id
        game.save!
      end
      true
    end

    def delete(ctx, model:, **)
      model.destroy
    end
  end
end