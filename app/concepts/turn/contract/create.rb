module Turn::Contract
  class Create < Reform::Form
    include Dry

    property :entry
    property :user_id
    property :game_id

    validation do
      params do
        required(:entry).filled
        required(:user_id).filled.value(:integer)
        required(:game_id).filled.value(:integer)
      end
  
      rule(:entry) do
        msg = "too short, must be more than " + Rails.configuration.entry_length_min.to_s + " letters"
        key.failure(msg) if value.length < Rails.configuration.entry_length_min
        msg = "too long, must be less than " + Rails.configuration.entry_length_max.to_s + " letters"
        key.failure(msg) if value.length > Rails.configuration.entry_length_max
      end
    end
  end
end
