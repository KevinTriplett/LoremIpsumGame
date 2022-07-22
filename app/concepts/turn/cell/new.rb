require 'json'

class Turn::Cell::New < Cell::ViewModel
  def show(&block)
    render(&block) # renders app/cells/turn/cell/show.haml
  end

  def user
    user = User.find(model.user_id)
  end

  def game
    user.game
  end

  def pad_name
    game.name.gsub(/\s/, '_')
  end

  def user_name
    user.name
  end

  def etherpad_settings
    {
      padId: pad_name,
      username: user_name,
      host: (Rails.env == "production" ? "https://loremipsumgame.com" : "http://127.0.0.1") + ":9001",
      height: 750
    }.to_json
  end
end