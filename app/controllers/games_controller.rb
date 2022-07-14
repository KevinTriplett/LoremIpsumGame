class GamesController < ApplicationController
  def show
    if current_user
      @game = Game.find(current_user.game_id)
    else
      not_found
    end
  end
end