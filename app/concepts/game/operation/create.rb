module Game::Operation
  class Create < Trailblazer::Operation
    
    class Present < Trailblazer::Operation
      step Model(Game, :new)
      step Contract::Build(constant: Game::Contract::Create)
    end
    
    step Subprocess(Present)
    step Contract::Validate(key: :game)
    step Contract::Persist()
  end
end