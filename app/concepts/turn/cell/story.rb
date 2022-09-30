require 'json'

class Turn::Cell::Story < Cell::ViewModel
  def show
    render # renders app/cells/turn/cell/new/show.haml
  end

  def user
    model.reload # get any updates from Turn::Operation::Present operation
  end

  def game
    user.game
  end

  def game_name
    game.name + (game.paused? ? " (paused)" : "")
  end

  def pad_name
    game.token
  end

  def players
    game.players
  end

  def current_player_id
    game.current_player_id
  end

  def current_player_name
    # refresh to pick up new current player
    User.find(game.current_player_id).name
  end

  def current_player?
    user.id == current_player_id
  end

  def do_not_load_pad?
    !current_player? || game.paused
  end

  def buttons
    return if do_not_load_pad?
    link_to("Finish Turn", user_turns_path, id: "finish", class: "btn btn-primary", data: { 
      turbo_method: "post",
      turbo_confirm: "Click OK if you are finished with your turn"
    }) +
    link_to("Pass", user_turns_path(pass: true), id: "pass", class: "btn btn-secondary", data: { 
      turbo_method: "post",
      turbo_confirm: "Click OK if you want to pass"
    })
  end

  def dataset
    return {class: "read-only"} if do_not_load_pad?
    pad_token = user.pad_token
    pad_token = nil if pad_token == "undefined"
    {
      data: {
        pad_id: pad_name,
        user_name: user.name,
        user_color: user.author_color.gsub("#", "%23"),
        host: Rails.configuration.etherpad_url,
        height: 600,
        url_token: pad_token ? nil : user_pad_token_url(token: user.token),
        pad_token: pad_token
      }
    }
  end

  def story
    do_not_load_pad? ? js_required_text : html_story
  end  

  def time_left_classes
    "time-left" + (game.turn_end && game.turn_end - Time.now < 0 ? " minus" : "")
  end

  def game_round
    "#{game.round} of #{game.num_rounds}"
  end

  def game_pause_or_end_label
    rounds_remaining = game.num_rounds - game.round + 1
    game.pause_rounds > 0 && rounds_remaining > game.pause_rounds ?
      "Pauses:" :
      "Ends:"
  end

  def game_pause_or_end_text
    return "Paused" if game.paused?
    rounds_remaining = game.num_rounds - game.round + 1
    rounds_remainder = game.pause_rounds > 0 ? game.round % game.pause_rounds : 0
    remaining = game.pause_rounds > 0 && rounds_remaining > game.pause_rounds ?
      (rounds_remainder > 0 ? game.pause_rounds - rounds_remainder + 1 : 0) :
      rounds_remaining
    remaining > 1 ? "in #{remaining} rounds" : "this round"
  end

  def turn_end
    game.paused? ? "game paused" : game.turn_end ? game.turn_end.iso8601 : "turn not started"
  end

  def turn_time_remaining
    return "game paused" if game.paused?
    return "turn not started" if game.turn_end.nil?
    time = game.turn_time_remaining
    "#{time[:hours]} hrs, #{time[:minutes]} mins" + (time[:hours] < 0 ? " (grace)" : "")
  end

  def html_story
    # see https://github.com/ether/etherpad-lite/issues/3750
    client = EtherpadLite.client(Rails.configuration.etherpad_url, Rails.configuration.etherpad_api_key)
    pad_id = Rails.env == "test" ? "test_story" : pad_name
    begin
      client.getHTML(padID: pad_id)[:html]
    rescue
      js_required_text
    end
  end

  def js_required_text
    "Something went wrong: 😭<br>Try refreshing the page 🤓<br>(Note: JavaScript is required) 🤔"
  end
end