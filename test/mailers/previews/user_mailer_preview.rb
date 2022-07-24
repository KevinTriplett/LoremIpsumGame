class UserMailerPreview < ActionMailer::Preview
  def welcome_email
    UserMailer.with(user: User.first).welcome_email
  end

  def turn_notification
    UserMailer.with(user: User.first).turn_notification
  end
end