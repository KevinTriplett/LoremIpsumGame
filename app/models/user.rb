class User < ActiveRecord::Base
  belongs_to :game
  has_many :turns, dependent: :destroy

  has_secure_token
  
  def remind
    begin
      UserMailer.turn_reminder(self).deliver_now
      self.reminded = true
      save!
    rescue => detail
      print detail.backtrace.join("\n")
      Rails.logger.error "in #remind for user #{self.inspect}"
      Rails.logger.error detail.to_s
    end
  end

  def auto_finish_turn
    begin
      # auto-finish turn
      # the create turn operation updates the current player and
      # sends the new player their turn notification
      Turn::Operation::Create.call(
        params: {
          turn: {}
        },
        user_id: self.id
      )
    rescue => detail
      print detail.backtrace.join("\n")
      Rails.logger.error "in #auto_finish_turn for user #{self.inspect}"
      Rails.logger.error detail.to_s
    end
  end

  # class methods executed by cron job
  def self.remind_players
    Game.all.each do |g|
      user = g.current_player
      next if g.ended? || g.no_reminder_yet? || user.reminded?
      user.remind
    end
  end

  def self.auto_finish_turns
    Game.all.each do |g|
      # indefinite last turns
      next if g.ended? || g.last_turn? || g.no_auto_finish_yet?
      g.current_player.auto_finish_turn
    end
  end
end