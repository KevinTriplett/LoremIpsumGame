class GameMailer < ApplicationMailer
  def pause_notification
    @game = params[:game]
    admins = @game.get_admins.pluck(:email)
    admins = @game.users.pluck(:email) unless admins.count > 0
    mail(to: admins, subject: "[Lorem Ipsum] Game paused!")    
  end
end