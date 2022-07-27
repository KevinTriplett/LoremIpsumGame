module Game::Contract
  class Create < Reform::Form
    include Dry

    property :id
    property :name
    property :game_days
    property :turn_hours

    validation do
      params do
        required(:id)
        required(:name).filled.value(:string)
      end

      rule(:name, :id) do
        game = Game.find_by_name(values[:name])
        key.failure('must be unique') if game && game.id != values[:id]
      end
    end
  end
end
