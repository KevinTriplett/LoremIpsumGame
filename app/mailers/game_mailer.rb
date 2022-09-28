class GameMailer < ApplicationMailer
  def pause_notification
    @game = params[:game]
    @url = "https://loremipsumgame.com/admin/games"
    @admins = @game.get_admins.pluck(:email)
    # no admins? send email to users
    @admins = @game.users.pluck(:email) if @admins.count == 0
    mail(to: @admins, subject: "Lorem Ipsum - Game paused")
  end
end