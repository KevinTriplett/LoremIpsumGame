class UserMailer < ApplicationMailer
  default from: 'notifications@loremipsumgame.com'

  def welcome
    @user = params[:user]
    @url  = 'http://loremipsumgame.com/' + @user.id
    @game = @user.game
    mail(to: @user.email, subject: 'Welcome to the Lorem Ipsum Game')
  end
end