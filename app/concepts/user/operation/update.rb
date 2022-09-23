module User::Operation
  class Update < Trailblazer::Operation

    class Present < Trailblazer::Operation
      step Model(User, :find_by, :token)
      step Contract::Build(constant: User::Contract::Create) # reuse the validations
    end
    
    step Subprocess(Present)
    step Contract::Validate(key: :user)
    step Contract::Persist()
    step :notify

    def notify(ctx, **)
      # TODO: only send if email address changed
      # TODO: send turn notification instead if suer is current player
      user = ctx[:model]
      if user.id == user.game.current_player_id
        UserMailer.with(user: user).turn_notification.deliver_now
      else
        UserMailer.with(user: user).welcome_email.deliver_now
      end
    end
  end
end