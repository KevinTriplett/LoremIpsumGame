class Game::Operation::Index < Trailblazer::Activity
  step :get_game

  def get_game
    Game.last
  end
end