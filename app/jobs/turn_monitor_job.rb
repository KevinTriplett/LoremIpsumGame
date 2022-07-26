class TurnMonitorJob < ApplicationJob
  @queue = :default

  def perform(user_id)
    user = User.find(user_id)
    game = user.game
    if game.current_player_id == user.id
      if game.turn_end > Time.now
        UserMailer.turn_reminder(user).deliver_now
      elsif !game.last_turn? # last turn is indefinite
        # auto-finish turn
        result = Turn::Operation::Create.wtf?(
          params: {
            turn: {}
          },
          user_id: user.id
        )
      end
    end
  end
end
