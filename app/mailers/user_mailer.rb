class UserMailer < ApplicationMailer

  def welcome_email
    init_locals_and_headers
    mail(to: @user.email, cc: @admins, subject: "Lorem Ipsum - Welcome to the Game")
  end

  def goodbye_email
    init_locals_and_headers
    mail(to: @user.email, cc: @admins, subject: "Lorem Ipsum - Sorry to see you go")
  end

  def turn_notification
    init_locals_and_headers
    @players = @game.get_who_played_since(@user)
    mail(to: @user.email, cc: @admins, subject: "Lorem Ipsum - Yay! It's Your Turn")
  end

  def turn_reminder
    init_locals_and_headers
    @players = @game.get_who_played_since(@user)
    mail(to: @user.email, cc: @admins, subject: "Lorem Ipsum - Reminder: It's Your Turn")
  end

  def game_ended
    init_locals_and_headers
    mail(to: @user.email, subject: "Lorem Ipsum - It's Done! Time to Celebrate!")
  end

  def turn_auto_finished
    init_locals_and_headers
    mail(to: @user.email, cc: @admins, subject: "Lorem Ipsum - Your turn was finished for you")
  end

  def group_alert
    init_locals_and_headers
    body = params[:body]
    subject = "Lorem Ipsum - " + params[:subject]
    mail(to: @user.email, subject: subject, body: body, content_type: "text/plain")
  end

  private

  def init_locals_and_headers
    @user = params[:user]
    @game = @user.game
    @url = "https://loremipsumgame.com/users/#{ @user.token }/turns/new"
    @admins = @game.get_admins.pluck(:email)
    unsubscribe_url = "https://loremipsumgame.com/users/#{ @user.token }/unsubscribe"
    headers['List-Unsubscribe'] = "<#{unsubscribe_url}>"
  end
end