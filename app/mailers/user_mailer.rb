class UserMailer < ApplicationMailer
  default from: 'notifications@loremipsumgame.com'

  def welcome_email
    @user = params[:user]
    @url  = 'http://127.0.0.1:3000/users/' + @user.token
    @game = @user.game
    mail(to: @user.email, subject: 'Welcome to the Lorem Ipsum Game')
  end
end