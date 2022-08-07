module User::Contract
  class Create < Reform::Form
    include Dry

    property :id
    property :name
    property :email
    property :game_id

    validation do
      params do
        required(:id)
        required(:name).filled
        required(:email).filled
        required(:game_id).filled.value(:integer)
      end
  
      rule(:email, :id, :game_id) do
        email, game_id = values[:email], values[:game_id]
        unless /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i.match?(email)
          key.failure('has invalid format')
        end

        user = User.find_by_email_and_game_id(email, game_id)
        key.failure('must be unique') if !user.nil? && user.id != values[:id].to_i
      end
    end
  end
end
