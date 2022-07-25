class UsersController < ApplicationController
  def show
    return not_found unless current_user && current_game
    user_token = session[:user_token]
    redirect_to (current_player? ? new_user_turn_path(user_token) : user_turns_path(user_token))
  end
end
