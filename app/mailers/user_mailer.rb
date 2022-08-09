class UserMailer < ApplicationMailer
  default from: "noreply@loremipsumgame.com"

  def welcome_email(user)
    @user = user
    @game = @user.game
    @url = get_url(user)
    mail(to: user.email, cc: admin_email, subject: '[Lorem Ipsum] Welcome to the Game 🤗')
  end

  def turn_notification(user)
    @user = user
    @url = get_url(user)
    mail(to: user.email, cc: admin_email, subject: "[Lorem Ipsum] Yay! It's Your Turn! 🥳")
  end

  def turn_reminder(user)
    @user = user
    @url = get_url(user)
    mail(to: user.email, cc: admin_email, subject: "[Lorem Ipsum] Reminder: It's Your Turn 😅")
  end

  def game_ended(user)
    @user = user
    @url = get_url(user)
    mail(to: user.email, cc: admin_email, subject: "[Lorem Ipsum] It's Done! Time to Celebrate! 🎉")
  end

  private

  def get_url(user)
    (Rails.env == 'production' ?
      'https://loremipsumgame.com/users/' :
      'http://127.0.0.1:3000/users/') +
      user.token + "/turns/new"
  end

  def admin_email
    "kt@kevintriplett.com"
  end
end