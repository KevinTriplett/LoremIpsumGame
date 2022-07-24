class UserMailer < ApplicationMailer
  default from: 'notifications@loremipsumgame.com'

  def welcome_email(user)
    @user = user
    @game = @user.game
    @url  = (Rails.env == 'production' ?
      'https://loremipsumgame.com/' :
      'http://127.0.0.1:3000/users/') +
      @user.token + "/turns/new"
    mail(to: @user.email, subject: '[Lorem Ipsum] Welcome to the Game')
  end

  def turn_notification(user)
    @user = user
    @url = (Rails.env == 'production' ?
      'https://loremipsumgame.com/' :
      'http://127.0.0.1:3000/users/') +
      @user.token + "/turns/new"
    mail(to: @user.email, subject: "[Lorem Ipsum] Yay! It's Your Turn!")
  end
end