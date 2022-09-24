class UserMailer < ApplicationMailer

  def welcome_email
    @user = params[:user]
    @game = @user.game
    @url = get_url(@user)
    admins = @user.game.get_admins.pluck(:email)
    set_unsubscribe_header
    mail(to: @user.email, cc: admins, subject: '[Lorem Ipsum] Welcome to the Game 🤗')
  end

  def goodbye_email
    @user = params[:user]
    admins = @user.game.get_admins.pluck(:email)
    set_unsubscribe_header
    mail(to: @user.email, cc: admins, subject: "[Lorem Ipsum] Sorry to see you go 😭")
  end

  def turn_notification
    @user = params[:user]
    @url = get_url(@user)
    @players = @user.game.get_who_played_since(@user)
    admins = @user.game.get_admins.pluck(:email)
    set_unsubscribe_header
    mail(to: @user.email, cc: admins, subject: "[Lorem Ipsum] Yay! It's Your Turn! 🥳")
  end

  def turn_reminder
    @user = params[:user]
    @url = get_url(@user)
    @players = @user.game.get_who_played_since(@user)
    admins = @user.game.get_admins.pluck(:email)
    set_unsubscribe_header
    mail(to: @user.email, cc: admins, subject: "[Lorem Ipsum] Reminder: It's Your Turn 😅")
  end

  def game_ended
    @user = params[:user]
    @url = get_url(@user)
    admins = @user.game.get_admins.pluck(:email)
    set_unsubscribe_header
    mail(to: @user.email, cc: admins, subject: "[Lorem Ipsum] It's Done! Time to Celebrate! 🎉")
  end

  def turn_auto_finished
    @user = params[:user]
    @url = get_url(@user)
    admins = @user.game.get_admins.pluck(:email)
    set_unsubscribe_header
    mail(to: @user.email, cc: admins, subject: "[Lorem Ipsum] Your turn was finished for you 🫣")
  end

  private

  def get_url(user)
    "https://loremipsumgame.com/users/#{ user.token }/turns/new"
  end

  def set_unsubscribe_header
    unsubscribe_url = "https://loremipsumgame.com/users/#{ @user.token }/unsubscribe"
    headers['List-Unsubscribe'] = "<#{unsubscribe_url}>"
  end
end