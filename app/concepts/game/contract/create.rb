module Game::Contract
  class Create < Reform::Form
    include Dry

    property :id
    property :name
    property :token
    property :turn_hours
    property :num_rounds

    validation do
      params do
        required(:id)
        required(:name).filled.value(:string)
        required(:turn_hours).filled.value(:integer)
        required(:num_rounds).filled.value(:integer)
      end

      rule(:name, :id) do
        game = Game.find_by_name(values[:name])
        key.failure('must be unique') if game && game.id != values[:id].to_i
      end
    end
  end
end
