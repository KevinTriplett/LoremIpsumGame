require 'etherpad-lite/client'

class Turn::Operation::Update < Trailblazer::Operation

  class Present < Trailblazer::Operation
    step Model(Turn, :new)
    step :initialize_attributes
    step Contract::Build(constant: Turn::Contract::Create)

    def initialize_attributes(ctx, model:, **)
      model.user_id = ctx[:user_id]
      model.game_id = ctx[:game_id]
    end
  end
  
  step Subprocess(Present)
  step :initialize_attributes
  step Contract::Persist()

  def initialize_attributes(ctx, model:, **)
    game = model.game
    return true if Rails.env == "test"
    client = EtherpadLite.client(Rails.configuration.etherpad_url, Rails.configuration.etherpad_api_key)
    model.entry = client.getHTML(padID: game.token)[:html]
  end
end
