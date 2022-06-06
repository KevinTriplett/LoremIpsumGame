class Game::Operation::Index < Trailblazer::Activity
    step :get_game
    step :view_game

    def get_game
        Game.last
    end

    def view_game
        
    end
end