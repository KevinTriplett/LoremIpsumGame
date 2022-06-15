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
  
      rule(:email) do
        unless /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i.match?(value)
          key.failure('has invalid format')
        end
      end
    end
  end
end
