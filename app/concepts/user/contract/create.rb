module User::Contract
  class Create < Reform::Form
    include Dry

    property :name
    property :email
    property :game_id

    validation do
      params do
        required(:name).filled
        required(:email).filled
        required(:game_id).filled.value(:integer)
      end
  
      rule(:email, :game_id) do
        email, game_id = values[:email], values[:game_id]
        unless /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i.match?(email)
          key.failure('has invalid format')
        end

        key.failure('must be unique') if User.find_by_email_and_game_id(email, game_id)
      end
    end
  end
end
