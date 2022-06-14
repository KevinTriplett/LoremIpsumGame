class User::Operation::Create < Trailblazer::Operation
  class Validations < Dry::Validation::Contract
    params do
      required(:name).filled
      required(:email).filled
      required(:game_id).filled.value(:integer)
    end

    rule(:email) do
      unless /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i.match?(value)
        key.failure('has invalid format')
      end
    end
  end

  step Contract::Validate(constant: Validations.new, key: :user)
  step :create_model
  step :initialize_game
  step :notify

  def create_model(ctx, **)
    ctx[:user] = User.new(**ctx["result.contract.default"].to_h)
    ctx[:user].save
  end

  def initialize_game(ctx, user:, **)
    game = Game.find(user.game_id)
    game.current_player_id ||= user.id
    game.save
  end

  def notify(ctx, user:, **)
    UserMailer.with(params: user).welcome
  end
end