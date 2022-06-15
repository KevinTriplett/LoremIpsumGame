module Game::Contract
  class Create < Reform::Form
    include Dry

    property :name

    validation do
      params do
        required(:name).filled
      end
    end
  end
end
