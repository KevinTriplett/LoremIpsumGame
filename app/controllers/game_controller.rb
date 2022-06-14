class GameController < ApplicationController
  def show
    @game = Game.last
  end
  
  def new
    @form = GameForm.new(Game.new)
  end

  def create
    run Game::Operation::Create do |ctx|
      redirect_to users_path(User.new) # next step: add user to the game
    end
  end
end