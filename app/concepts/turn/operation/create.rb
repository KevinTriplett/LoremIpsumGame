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
    model.entry = ctx[:pass] ? "pass" : "test"
    return true if ctx[:pass] || Rails.env == "test"

    client = EtherpadLite.client(Rails.configuration.etherpad_url, Rails.configuration.etherpad_api_key)
    model.entry = client.getHTML(padID: game.token)[:html]
    client.saveRevision(padID: game.token)
    model.revision = client.listSavedRevisions(padID: game.token)[:savedRevisions].max
  end

  def update_game(ctx, model:, **)
    game = model.game
    if game.round_finished?
      game.round += 1
      game.users.each(&:reset_reminded)
      game.shuffle_players
      game.current_player_id = game.players.first.id
    else
      game.current_player_id = game.next_player_id
    end
    game.started ||= Time.now
    game.turn_start = Time.now
    game.turn_end = game.turn_start + game.turn_hours.hours
    game.save
  end

  def notify(ctx, model:, **)
    game = model.game
    return true if game.ended?
    if game.round > game.num_rounds || game.players_finished?
      game.users.each { |u| UserMailer.with(user: u).game_ended.deliver_now }
      game.update(ended: Time.now)
    else
      user = game.current_player
      UserMailer.with(user: user).turn_notification.deliver_now
    end
  end
end
