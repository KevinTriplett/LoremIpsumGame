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
    game_name.gsub(/\s/, '_')
  end

  def users
    game.users
  end

  def current_player_id
    game.current_player_id
  end

  def current_player?
    user.id == current_player_id
  end

  def finish_button
    current_player? && html_story ?
      link_to("Finish Turn", user_turns_path, class: "btn btn-primary", data: { turbo_method: "post", turbo_confirm: "Click OK if you are finished with your turn" })
      : nil
  end

  def etherpad_script
    current_player? ?
      "<script>$(document).ready( $('#ep').pad(#{etherpad_settings}) );</script>"
      : nil
  end

  def etherpad_settings
    {
      padId: pad_name,
      username: user.name,
      host: "http://127.0.0.1:9001",
      height: 750
    }.to_json
  end

  def story
    current_player? ?
      "Something went wrong: unable to access the document 😭"
      : html_story
  end  

  def game_start
    game.game_start ? game.game_start.strftime("%m %-d, %Y") : "Game not started yet"
  end

  def game_end
    game.game_end ? game.game_end.strftime("%m %-d, %Y") : "Game not started yet"
  end

  def turn_start
    game.turn_start ? game.turn_start.strftime("%l:%M %P (%a %-m/%-d)") : "Turn not started yet"
  end

  def turn_end
    game.turn_end ? game.turn_end.strftime("%l:%M %P on (%a %-m/%-d)") : "Turn not started yet"
  end

  def html_story
    # see https://github.com/ether/etherpad-lite/issues/3750
    client = EtherpadLite.client(9001, Rails.configuration.etherpad_api_key)
    pad_id = Rails.env == "test" ? "test_story" : pad_name
    begin
      client.getHTML(padID: pad_id)[:html]
    rescue
      nil
    end
  end
end