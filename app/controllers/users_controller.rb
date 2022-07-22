class UsersController < ApplicationController
  def show
    return not_found unless current_user && current_game
    user_token = { user_token: params[:token] }
    redirect_to current_user_turn? ? new_user_turn_path(user_token) : redirect_to user_turns_path(user_token)
  end
end
