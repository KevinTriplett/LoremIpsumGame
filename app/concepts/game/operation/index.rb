class Game::Operation::Index < Trailblazer::Operation
  step :get_game

  def get_game
    Game.last
  end
end