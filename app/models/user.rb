class User < ActiveRecord::Base
  belongs_to :game
  has_many :turns, dependent: :destroy

  has_secure_token
  
  scope :next_player, ->(user_id, game_id) { 
    where("id > ?", user_id).first ||
    where("game_id = ?", game_id).first
  }
end