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
    step :create_pad

    def initialize_rules(ctx, **)
      return true unless ctx[:params][:game]
      ctx[:params][:game][:game_days] ||= Rails.configuration.default_game_days
      ctx[:params][:game][:turn_hours] ||= Rails.configuration.default_turn_hours
    end

    def create_pad(ctx, model:, **)
      begin
        game = Game.find(model.id)
        client = EtherpadLite.client(Rails.configuration.etherpad_url, Rails.configuration.etherpad_api_key)
        nil == client.createPad(padID: game.token)
      rescue
        puts "ERROR: pad '#{game.token}' could not be created"
        true
      end
    end
  end
end