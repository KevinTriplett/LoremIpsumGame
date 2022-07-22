class Game::Cell::Show < Cell::ViewModel
  property :name
  property :users
  property :current_player
  property :current_player_id
  property :game_start
  property :game_end
  property :turn_start
  property :turn_end

  def show(&block)
    render(&block) # renders app/cells/game/cell/show.haml
  end

  def pad_name
    name.gsub(/\s/, '_')
  end
end