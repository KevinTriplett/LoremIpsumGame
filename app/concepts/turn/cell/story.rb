require 'json'

class Turn::Cell::Story < Cell::ViewModel
  def show
    render # renders app/cells/turn/cell/new/show.haml
  end

  def user
    model
  end

  def game
    user.game
  end

  def game_name
    game.name
  end

  def pad_name
    game.token
  end

  def users
    game.users
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

  def finish_button
    current_player? ?
      link_to("Finish Turn", user_turns_path, class: "btn btn-primary", data: { 
        turbo_method: "post",
        turbo_confirm: "Click OK if you are finished with your turn"
      }) : nil
  end

  def dataset
    return {} unless current_player?
    {
      data: {
        pad_id: pad_name,
        user_name: user.name,
        host: Rails.configuration.etherpad_url,
        height: 600
      }
    }
  end

  def story
    current_player? ? js_required_text : html_story
  end  

  def time_left_classes
    "time-left" + (game.turn_end && game.turn_end - Time.now < 0 ? " minus" : "")
  end

  def game_start
    game.game_start ? game.game_start.iso8601 : nil
  end

  def game_end
    game.game_end ? game.game_end.iso8601 : nil
  end

  def game_ends
    days = game.game_end ?
      (game.game_end - Time.now).to_i/60/60/24.round :
      game.game_days
    "in " + pluralize(days, "day")
  end

  def turn_start
    game.turn_start ? game.turn_start.iso8601 : nil
  end

  def turn_end
    game.turn_end ? game.turn_end.iso8601 : nil
  end

  def turn_time_remaining
    return nil unless game.turn_end
    hours = (game.turn_end - Time.now).to_i/60/60.floor
    minutes = ((game.turn_end - Time.now).to_f/60 % 60).floor
    "#{hours} hours, #{minutes} minutes" + (hours < 0 ? " (in grace period)" : "")
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