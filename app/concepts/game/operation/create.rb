module Game::Operation
  class Create < Trailblazer::Operation
    
    class Present < Trailblazer::Operation
      step Model(Game, :new)
      step :initialize_attributes
      step Contract::Build(constant: Game::Contract::Create)

      def initialize_attributes(ctx, **)
        ctx[:model].round = 1
      end
    end
    
    step Subprocess(Present)
    step Contract::Validate(key: :game)
    step Contract::Persist()
    step :create_pad

    def create_pad(ctx, model:, **)
      begin
        game = Game.find(model.id)
        client = EtherpadLite.client(Rails.configuration.etherpad_url, Rails.configuration.etherpad_api_key)
        nil == client.createPad(padID: game.token, text: Rails.configuration.initial_etherpad_text)
      rescue
        puts "ERROR: pad '#{game.token}' could not be created" unless Rails.env == "test"
        true
      end
    end
  end
end