class TurnMailer < ApplicationMailer
  default from: 'notifications@loremipsumgame.com'

  def turn_notification
    @turn = params[:turn]
    @user = @turn.user
    @url  = 'http://loremipsumgame.com/' + @user.id
    @game = @turn.game
    @this_player = (game.current_player_id == @user.id)
    subject = "[Lorem Ipsum Game] " + (@this_player ? "Yay! It's Your Turn!" : "Turn Notification")
    mail(to: @user.email, subject: subject)
  end
end