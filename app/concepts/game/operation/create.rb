module Game::Operation
  class Create < Trailblazer::Operation
    
    class Present < Trailblazer::Operation
      step Model(Game, :new)
      step Contract::Build(constant: Game::Contract::Create)
    end
    
    step Subprocess(Present)
    step :initialize_rules
    step Contract::Validate(key: :game)
    step Contract::Persist()

    def initialize_rules(ctx, **)
      return true unless ctx[:params][:game]
      ctx[:params][:game][:game_days] ||= Rails.configuration.default_game_days
      ctx[:params][:game][:turn_hours] ||= Rails.configuration.default_turn_hours
    end
  end
end