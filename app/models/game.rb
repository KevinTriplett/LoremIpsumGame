class Game < ActiveRecord::Base
  has_many :users, dependent: :destroy

  has_secure_token

  def current_player
    User.find(current_player_id)
  end

  def next_player_id
    # rollover if at the end of the user array
    (users.where("id > ?", current_player_id).first || users.first).id
  end

  def last_turn?
    turn_end && game_end && turn_end > game_end
  end

  def ended?
    game_end && Time.now > game_end
  end

  def no_reminder_yet?
    Time.now < (turn_end - turn_reminder_hours)
  end

  def no_auto_finish_yet?
    Time.now < (turn_end + grace_period_hours)
  end

  private

  def turn_reminder_hours
    (turn_hours / 2).hours
  end

  # TODO: can make this configurable on the model
  def grace_period_hours
    turn_hours / 4
  end
end