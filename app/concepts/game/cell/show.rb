class Game::Cell::Show < Cell::ViewModel
  property :name
  property :turns
  property :users
  property :game_start
  property :game_end
  property :turn_start
  property :turn_end

  def show
    render # renders app/cells/game/cell/show.haml
  end
end