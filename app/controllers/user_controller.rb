class UserController < ApplicationController
  def new
    @form = GameForm.new(User.new)
  end

  def create
    run User::Create do |ctx|
      redirect_to users_path(User.new) # next step: add next user to the game
    end
  end
end
