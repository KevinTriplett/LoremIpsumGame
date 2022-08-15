class Turn < ActiveRecord::Base
  belongs_to :user
  belongs_to :game

  def self.round_count(game_id, round)
    where(game_id: game_id).where(round: round).count
  end
end