class Game::Cell < Cell::ViewModel
  property :name
  property :turns
  property :users
  property :game_start
  property :game_end
  property :turn_start
  property :turn_end

  def show
    render # renders app/concepts/game/views/show.haml
  end
end