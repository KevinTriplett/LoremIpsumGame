class UserMailer < ApplicationMailer

  def welcome_email
    @user = params[:user]
    @game = @user.game
    @url = get_url(@user)
    admins = @user.game.get_admins.pluck(:email)
    mail(to: @user.email, cc: admins, subject: '[Lorem Ipsum] Welcome to the Game 🤗')
  end

  def goodbye_email
    @user = params[:user]
    admins = @user.game.get_admins.pluck(:email)
    mail(to: @user.email, cc: admins, subject: "[Lorem Ipsum] Sorry to see you go 😭")
  end

  def turn_notification
    @user = params[:user]
    @url = get_url(@user)
    @players = @user.game.get_who_played_since(@user)
    admins = @user.game.get_admins.pluck(:email)
    mail(to: @user.email, cc: admins, subject: "[Lorem Ipsum] Yay! It's Your Turn! 🥳")
  end

  def turn_reminder
    @user = params[:user]
    @url = get_url(@user)
    @players = @user.game.get_who_played_since(@user)
    admins = @user.game.get_admins.pluck(:email)
    mail(to: @user.email, cc: admins, subject: "[Lorem Ipsum] Reminder: It's Your Turn 😅")
  end

  def game_ended
    @user = params[:user]
    @url = get_url(@user)
    admins = @user.game.get_admins.pluck(:email)
    mail(to: @user.email, cc: admins, subject: "[Lorem Ipsum] It's Done! Time to Celebrate! 🎉")
  end

  def turn_auto_finished
    @user = params[:user]
    @url = get_url(@user)
    admins = @user.game.get_admins.pluck(:email)
    mail(to: @user.email, cc: admins, subject: "[Lorem Ipsum] Your turn was finished for you 🫣")
  end

  private

  def get_url(user)
    (Rails.env == 'production' ?
      'https://loremipsumgame.com/users/' :
      'https://127.0.0.1:3000/users/') +
      user.token + "/turns/new"
  end
end