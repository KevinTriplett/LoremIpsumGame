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
    step :create_pad
    step Contract::Persist()

    def create_pad(ctx, model:, **)
      return true if Rails.env == "test"
      game = Game.find(model.id)
      client = EtherpadLite.client(Rails.configuration.etherpad_url, Rails.configuration.etherpad_api_key)
      nil == client.createPad(padID: game.token, text: Rails.configuration.initial_etherpad_text)
    end
  end
end