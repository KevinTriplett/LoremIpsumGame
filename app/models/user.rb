class User < ActiveRecord::Base
  belongs_to :game
  has_many :turns, dependent: :destroy

  has_secure_token

  def reset_reminded!
    self.reminded = nil
    save!
  end

  def remind
    return if reminded?
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

  def finish_turn
    begin
      # auto-finish turn
      # Turn::Operation::Create updates current_player and
      # notifies the new current_player
      Turn::Operation::Create.call(
        params: {
          turn: {}
        },
        user_id: id
      )
    rescue => detail
      print detail.backtrace.join("\n")
      Rails.logger.error "in #auto_finish_turn for user #{self.inspect}"
      Rails.logger.error detail.to_s
    end
  end
end