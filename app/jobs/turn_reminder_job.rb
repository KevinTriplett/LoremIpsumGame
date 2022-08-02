class TurnReminderJob < ApplicationJob
  @queue = :default

  def perform(user_id, turns_count)
    user = User.find(user_id)
    return if user.turns.count != turns_count

    # user has not taken their turn (turns.count has not changed)
    # so remind them
    UserMailer.turn_reminder(user).deliver_now
  end
  handle_asynchronously :perform
end
