module Game::Operation
  class Update < Trailblazer::Operation

    class Present < Trailblazer::Operation
      step Model(Game, :find_by)
      step Contract::Build(constant: Game::Contract::Create) # reuse the validations
    end
    
    step Subprocess(Present)
    step Contract::Validate(key: :game)
    step Contract::Persist()
  end
end