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
      UserMailer.with(user: self).turn_reminder.deliver_now
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
      UserMailer.with(user: self).turn_auto_finished.deliver_now
    rescue => detail
      print detail.backtrace.join("\n")
      Rails.logger.error "in #auto_finish_turn for user #{self.inspect}"
      Rails.logger.error detail.to_s
    end
  end

  def self.pick_author_color(i)
    i = i % Rails.configuration.author_colors.count
    Rails.configuration.author_colors[i]
  end
end