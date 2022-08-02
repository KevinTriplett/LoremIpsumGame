class TurnFinishJob < ApplicationJob
  @queue = :default

  def perform(user_id, turns_count)
    user = User.find(user_id)
    game = user.game
    return if user.turns.count != turns_count

    # auto-finish turn
    # the operation sends end of game notifications
    result = Turn::Operation::Create.call(
      params: {
        turn: {}
      },
      user_id: user.id
    )
  end
  handle_asynchronously :perform
end
