module User::Operation
  class Update < Trailblazer::Operation

    class Present < Trailblazer::Operation
      step Model(User, :find_by)
      step Contract::Build(constant: User::Contract::Create) # reuse the validations
    end
    
    step Subprocess(Present)
    step Contract::Validate(key: :user)
    step Contract::Persist()
    step :notify

    def notify(ctx, **)
      user = ctx[:model]
      UserMailer.with(user: user).welcome_email.deliver_now
    end
  end
end