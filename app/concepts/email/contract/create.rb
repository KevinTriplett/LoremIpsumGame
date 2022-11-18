module Email::Contract
  class Create < Reform::Form
    include Dry

    property :subject
    property :body
    property :game_id

    validation do
      params do
        required(:subject).filled.value(:string)
        required(:body).filled.value(:string)
      end
    end
  end
end
