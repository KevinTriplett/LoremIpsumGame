module Game::Operation
  class Delete < Trailblazer::Operation
    step Model(Game, :find_by)
    step :delete

    def delete(ctx, model:, **)
      model.destroy
    end
  end
end