class Game < ActiveRecord::Base
  has_many :users, dependent: :destroy
  has_one :current_player, class_name: "User"

  has_secure_token

  def last_turn?
    turn_end && game_end && turn_end > game_end
  end

  def turn_reminder_hours
    (turn_hours / 2).hours
  end

  def turn_autofinish_hours
    (turn_hours + grace_period).hours
  end

  # TODO: can make this configurable on the model
  def grace_period
    turn_hours / 4
  end
end