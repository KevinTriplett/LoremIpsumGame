module Email::Operation
  class Create < Trailblazer::Operation
    
    class Present < Trailblazer::Operation
      step Model(Email, :new)
      step Contract::Build(constant: Email::Contract::Create)
    end
    
    step Subprocess(Present)
    step Contract::Validate(key: :email)
    step :send_email

    def send_email(ctx, **)
      params = ctx[:params]
      game = Game.find(params[:game_id])
      params = params[:email]
      s = params[:subject]
      b = params[:body]
      game.users.each do |u|
        UserMailer.with(user: u, subject: s, body: b).group_alert.deliver_now
      end
      true
    end
  end
end