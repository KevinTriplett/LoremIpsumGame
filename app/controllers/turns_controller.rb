class TurnsController < ApplicationController
  def index
    @user = get_user
    render
  end

  def new
    return redirect_to user_turns_url unless current_player?
    @user = get_user

    run Turn::Operation::Create::Present, user_id: @user.id do |ctx|
      return render
    end

    redirect_to user_turns_url
  end

  def create
    @user = get_user
    if current_player?
      run Turn::Operation::Create, user_id: @user.id do |ctx|
        flash[:notice] = "Turn has been completed and saved - thank you!"
        return redirect_to user_turns_url
      end
    else # player must have hit their back button and re-submitted
      flash[:notice] = "Turn has been completed again and saved - thank you!"
      return redirect_to user_turns_url
    end

    render :new
  end

  private

  def get_user
    User.find_by_token(params[:user_token])
  end
end
