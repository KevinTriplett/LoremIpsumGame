module Game::Operation
  class Delete < Trailblazer::Operation
    step Model(Game, :find_by)
    step :delete
    step :delete_pad

    def delete(ctx, model:, **)
      model.destroy
    end

    def delete_pad(ctx, model:, **)
      begin
        client = EtherpadLite.client(Rails.configuration.etherpad_url, Rails.configuration.etherpad_api_key)
        nil == client.deletePad(padID: model.token)
      rescue
        puts "Pad #{model.token} not found" unless Rails.env == "test"
        true
      end
    end
  end
end