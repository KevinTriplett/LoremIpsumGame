module User::Operation
  class Index < Trailblazer::Operation
    step :find_all_by_game

    def find_all_by_game(ctx, **)
      game_id = ctx[:params][:game_id]
      game = Game.find(game_id)
      ctx[:model] = game.players
      ctx[:game] = game
    end
  end
end