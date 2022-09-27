class UsersController < ApplicationController
  protect_from_forgery with: :null_session

  def index
    # game is entered through /users(/:user_token)/turns/new
    @body_class = "root"
    @page_title = " "
    render
  end

  def destroy
    @user = User.find_by_token(params[:token])
    run User::Operation::Delete do
      flash[:notice] = "You've been removed from #{@user.game.name}"
      return redirect_to root_url, status: :see_other
    end

    flash[:notice] = "Unable to unsubscribe you, contact Kevin Triplett (email below)"
    render :unsubscribe, status: :unprocessable_entity
  end

  def unsubscribe
    @user = User.find_by_token(params[:token])
    @body_class = "root"
    render
  end

  def pad_token
    user = User.find_by_token(params[:token])
    result = user.update(pad_token: params[:padToken])
    render json: {result: result}
  end
end
