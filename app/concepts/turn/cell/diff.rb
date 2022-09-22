require 'json'

class Turn::Cell::Diff < Cell::ViewModel
  def show
    render # renders app/cells/turn/cell/new/show.haml
  end

  def user
    model
  end

  def game_name
    model.game.name
  end

  def pad_name
    model.game.token
  end

  def diff
    # see https://github.com/ether/etherpad-lite/issues/3750
    client = EtherpadLite.client(Rails.configuration.etherpad_url, Rails.configuration.etherpad_api_key)
    pad_id = Rails.env == "test" ? "test_story" : pad_name
    puts "@user_last_turn.revision = " + context[:start_rev].to_s
    puts "@game_last_turn.revision = " + context[:end_rev].to_s
    begin
      client.createDiffHTML(padID: pad_id, startRev: context[:start_rev], endRev: context[:end_rev])[:html]
    rescue
      js_required_text
    end
  end

  def js_required_text
    "Something went wrong: 😭<br>Try refreshing the page 🤓<br>(Note: JavaScript is required) 🤔"
  end

  def buttons
    link_to("Return to Game", new_user_turn_path(user_token: user.token), class: "btn btn-primary")
  end
end