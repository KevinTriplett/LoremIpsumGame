module Game::Contract
  class Create < Reform::Form
    include Dry

    property :name

    validation do
      params do
        required(:name).filled
      end

      rule(:name) do
        key.failure('must be unique') if Game.find_by_name(value)
      end
    end
  end
end
