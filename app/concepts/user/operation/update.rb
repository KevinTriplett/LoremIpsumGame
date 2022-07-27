module User::Operation
  class Update < Trailblazer::Operation

    class Present < Trailblazer::Operation
      step Model(User, :find_by)
      step :get_game
      step Contract::Build(constant: User::Contract::Update)

      def get_game(ctx, **args)
        ctx[:game] = ctx[:model].game
      end
    end
    
    step Subprocess(Present)
    step Contract::Validate(key: :user)
    step Contract::Persist()
    step :notify

    def notify(ctx, **)
      user = ctx[:model]
      UserMailer.with(params: user).welcome_email
    end
  end
end