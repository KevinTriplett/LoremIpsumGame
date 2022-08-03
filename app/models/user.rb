class User < ActiveRecord::Base
  belongs_to :game
  has_many :turns, dependent: :destroy

  has_secure_token
  
  scope :next_player, ->(user_id, game_id) { 
    where("id > ?", user_id).first ||
    where("game_id = ?", game_id).first
  }

  def remind
    UserMailer.turn_reminder(self).deliver_now
    self.reminded = true
    save!
  end

  # class methods executed by cron job
  def self.remind_players
    games = Game.all
    games.each do |g|
      user = g.current_player
      next if g.ended? || g.no_reminder_yet? || user.reminded?
      user.remind
    end
  end

  def self.auto_finish_turns
    games = Game.all
    games.each do |g|
      user = g.current_player
      # indefinite last turns
      next if g.ended? || g.last_turn? || g.no_auto_finish_yet?
      # auto-finish turn
      # the operation sends end of game notifications
      result = Turn::Operation::Create.call(
        params: {
          turn: {}
        },
        user_id: user.id
      )
    end
  end
end