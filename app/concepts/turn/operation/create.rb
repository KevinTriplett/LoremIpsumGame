require 'etherpad-lite/client'

class Turn::Operation::Create < Trailblazer::Operation

  class Present < Trailblazer::Operation
    step Model(Turn, :new)
    step :initialize_user
    step Contract::Build(constant: Turn::Contract::Create)

    def initialize_user(ctx, model:, **)
      model.user_id = ctx[:user_id]
    end
  end
  
  step Subprocess(Present)
  step :initialize_entry
  step Contract::Persist()
  # TODO: exit with success if game.last_turn?
  step :update_game
  step :notify

  def initialize_entry(ctx, model:, **)
    return true if Rails.env == "test"
    game = model.game
    client = EtherpadLite.client(Rails.configuration.etherpad_url, Rails.configuration.etherpad_api_key)
    model.entry = client.getHTML(padID: game.token)[:html]
  end

  def update_game(ctx, model:, **)
    game = User.find(model.user_id).game
    game.game_start ||= Time.now
    game.game_end ||= game.game_start + game.game_days.days
    game.turn_start = Time.now
    game.turn_end = game.turn_start + game.turn_hours.hours
    game.current_player_id = User.next_player(model.user_id, game.id).id
    game.save!
  end

  def notify(ctx, model:, **)
    game = User.find(model.user_id).game
    if game.ended?
      game.users.each { |u| UserMailer.game_ended(u).deliver_now }
    else
      user = game.current_player
      UserMailer.turn_notification(user).deliver_now
    end
  end
end