require 'json'

class Turn::Cell::New < Cell::ViewModel
  def show
    render # renders app/cells/turn/cell/new/show.haml
  end

  def game_name
    model.name
  end

  def user
    context[:user]
  end

  def etherpad_settings
    pad_name = game_name.gsub(/\s/, '_')
    {
      padId: pad_name,
      username: user.name,
      host: (Rails.env == "production" ? "https://loremipsumgame.com" : "http://127.0.0.1") + ":9001",
      height: 750
    }.to_json
  end

  def users
    model.users
  end

  def current_player_id
    model.current_player_id
  end

  def game_start
    model.game_start.strftime("%m %-d, %Y")
  end

  def game_end
    model.game_end.strftime("%m %-d, %Y")
  end

  def turn_start
    model.turn_start.strftime("%l:%M %P (%a %-m/%-d)")
  end

  def turn_end
    model.turn_end.strftime("%l:%M %P on (%a %-m/%-d)")
  end
end