module User::Contract
  class Update < Reform::Form
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
  
      rule(:email, :name) do
        unless /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i.match?(values[:email])
          key.failure('has invalid format')
        end

        user = User.find_by_email(values[:email])
        key.failure('must be unique') if user && user.name != values[:name]
      end
    end
  end
end
