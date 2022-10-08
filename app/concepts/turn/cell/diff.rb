require 'json'

class Turn::Cell::Diff < Cell::ViewModel
  def show
    render # renders app/cells/turn/cell/new/show.haml
  end

  def user
    model
  end
  
  def game
    model.game
  end

  def game_name
    game.name
  end

  def players
    game.players
  end

  def current_player_id
    game.current_player_id
  end

  def pad_name
    game.token
  end

  def diff
    # see https://github.com/ether/etherpad-lite/issues/3750
    client = EtherpadLite.client(Rails.configuration.etherpad_url, Rails.configuration.etherpad_api_key)
    pad_id = Rails.env == "test" ? "test_story" : pad_name
    start_rev = context[:start_rev] ? context[:start_rev].revision : 0
    end_rev = context[:end_rev] ? context[:end_rev].revision : 9999
    begin
      client.createDiffHTML(padID: pad_id, startRev: start_rev, endRev: end_rev)[:html]
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
