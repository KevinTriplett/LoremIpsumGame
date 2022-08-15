module Game::Operation
  class Update < Trailblazer::Operation

    class Present < Trailblazer::Operation
      step Model(Game, :find_by)
      step Contract::Build(constant: Game::Contract::Create) # reuse the validations
    end
    
    step Subprocess(Present)
    step Contract::Validate(key: :game)
    step :update_turn_end
    step Contract::Persist()

    def update_turn_end(ctx, **)
      turn_hours, model = ctx[:params][:game][:turn_hours], ctx[:model]
      model.turn_end = model.turn_start ?
        model.turn_start + turn_hours.to_i.hours :
        model.turn_end
      true
    end
  end
end