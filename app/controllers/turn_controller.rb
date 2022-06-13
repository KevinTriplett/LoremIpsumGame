class UserController < ApplicationController
  def new
    @form = TurnForm.new(User.new)
  end

  def create
    run Turn::Create do |ctx|
      redirect_to game_path() # next step: show current game
    end
  end
end
