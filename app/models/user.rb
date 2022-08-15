class User < ActiveRecord::Base
  belongs_to :game
  has_many :turns, dependent: :destroy

  has_secure_token

  def reset_reminded
    update(reminded: nil)
  end

  def remind
    return if reminded?
    begin
      UserMailer.turn_reminder(self).deliver_now
      update(reminded: true)
    rescue => detail
      print detail.backtrace.join("\n")
      Rails.logger.error "in #remind for user #{self.inspect}"
      Rails.logger.error detail.to_s
    end
  end

  def finish_turn
    begin
      # Turn::Operation::Create updates current_player and
      # notifies the new current_player
      Turn::Operation::Create.call(
        params: {
          turn: {}
        },
        user_id: id,
        game_id: game_id
      )
      UserMailer.turn_auto_finished(self).deliver_now
    rescue => detail
      print detail.backtrace.join("\n")
      Rails.logger.error "in #auto_finish_turn for user #{self.inspect}"
      Rails.logger.error detail.to_s
    end
  end
end