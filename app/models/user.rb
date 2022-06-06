class User < ActiveRecord::Base
  belongs_to :game
  has_many :turns
  scope :next_user, ->(user_id, game_id) { 
    where("id > ?", user_id).first ||
    where("game_id = ?", game_id).first
  }
end