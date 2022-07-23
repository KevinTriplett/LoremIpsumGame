require 'etherpad-lite/client'

class Turn::Operation::Create < Trailblazer::Operation

  class Present < Trailblazer::Operation
    step Model(Turn, :new)
    step :initialize_user
    step :initialize_entry
    step Contract::Build(constant: Turn::Contract::Create)

    def initialize_user(ctx, model:, **)
      model.user_id = ctx[:user_id]
    end

    def initialize_entry(ctx, model:, **)
      client = EtherpadLite.client(9001, Rails.configuration.etherpad_api_key)
      pad_name = model.game.name.gsub(/\s/, '_')
      model.entry = Rails.env == "test" ? nil : client.getText(padID: pad_name)[:text]
      true
    end
  end
  
  step Subprocess(Present)
  # step Contract::Validate(key: :turn)
  step Contract::Persist()
  step :update_game
  step :notify

  def update_game(ctx, model:, **)
    game = User.find(model.user_id).game
    game.game_start ||= Time.now
    game.game_end ||= game.game_start + game.game_days.days
    game.turn_start = Time.now
    game.turn_end = game.turn_start + game.turn_hours.hours
    game.current_player_id = User.next_user(model.user_id, game.id).id
    game.save
  end

  def notify(ctx, model:, **)
    TurnMailer.with(turn: model).turn_notification
  end
end