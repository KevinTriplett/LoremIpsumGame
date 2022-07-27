class Game::Cell::Index < Cell::ViewModel
  property :name
  property :pad_name
  property :users
  property :current_player
  property :current_player_id
  property :game_start
  property :game_end
  property :turn_start
  property :turn_end

  def show
    render # renders app/cells/game/cell/index/show.haml
  end
end