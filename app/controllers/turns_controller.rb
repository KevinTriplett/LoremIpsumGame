class TurnsController < ApplicationController
  def index
    get_user
    render
  end

  def new
    return redirect_to user_turns_path unless current_player?
    session[:ep_sessions] ||= {}
    get_user

    run Turn::Operation::Create::Present, user_id: @user.id do |ctx|
      return render
    end

    redirect_to user_turns_path
  end

  def create
    return redirect_to user_turns_path unless current_player?
    session[:ep_sessions] ||= {}
    get_user

    run Turn::Operation::Create, user_id: @user.id do |ctx|
      flash[:notice] = "Turn has been completed and saved - thank you!"
      return redirect_to user_turns_path
    end
  
    render :new
  end

  private

  def get_user
    @user = User.find_by_token(params[:user_token])
  end
end
