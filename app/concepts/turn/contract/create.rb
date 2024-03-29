module Turn::Contract
  class Create < Reform::Form
    include Dry

    property :user_id
    property :game_id

    validation do
      params do
        required(:user_id).filled.value(:integer)
        required(:game_id).filled.value(:integer)
      end
    end
  end
end
