require 'etherpad-lite/client'

class Turn::Operation::Create < Trailblazer::Operation

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
  step :update_game
  step :notify

  def initialize_attributes(ctx, model:, **)
    game = model.game
    model.round = game.round
    return true if Rails.env == "test"
    client = EtherpadLite.client(Rails.configuration.etherpad_url, Rails.configuration.etherpad_api_key)
    model.entry = client.getHTML(padID: game.token)[:html]
  end

  def update_game(ctx, model:, **)
    game = model.game
    if game.players_finished?
      game.round += 1
      game.users.each(&:reset_reminded)
      game.shuffle_players
      game.current_player_id = game.players.first.id
    else
      game.current_player_id = game.next_player_id
    end
    game.turn_start = Time.now
    game.turn_end = game.turn_start + game.turn_hours.hours
    game.save
  end

  def notify(ctx, model:, **)
    game = model.game
    if game.game_ended?
      game.users.each { |u| UserMailer.game_ended(u).deliver_now }
    else
      user = game.current_player
      UserMailer.turn_notification(user).deliver_now
    end
  end
end
