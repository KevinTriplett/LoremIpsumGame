class Game < ActiveRecord::Base
  has_many :users, dependent: :destroy
  has_one :current_player, class_name: "User"

  has_secure_token

  def last_turn?
    turn_end && game_end && turn_end > game_end
  end
end