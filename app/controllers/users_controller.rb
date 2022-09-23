class UsersController < ApplicationController
  def index
    # game is entered through /users(/:user_token)/turns/new
    render
  end

  def destroy
    @user = User.find_by_token(params[:token])
    run User::Operation::Delete
    flash[:notice] = "You've been removed from #{@user.game.name}"
    redirect_to root_url, status: :unprocessable_entity
  end

  def unsubscribe
    @user = User.find_by_token(params[:token])
    render
  end
end
