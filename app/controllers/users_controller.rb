class UsersController < ApplicationController
  def show
    session[:current_user_id] = params[:id] if params[:id]
    redirect_to game_url(current_user.game_id)
  end
end
