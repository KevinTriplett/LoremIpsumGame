class UserMailerPreview < ActionMailer::Preview
  def game_ended
    UserMailer.with(user: User.first).game_ended
  end
  def goodbye_email
    UserMailer.with(user: User.first).goodbye_email
  end
  def turn_auto_finished
    UserMailer.with(user: User.first).turn_auto_finished
  end
  def turn_notification
    UserMailer.with(user: User.first).turn_notification
  end
  def turn_reminder
    UserMailer.with(user: User.first).turn_reminder
  end
  def welcome_email
    UserMailer.with(user: User.first).welcome_email
  end
end