class TurnsController < ApplicationController
  def index
    @user = get_user
    render
  end

  def new
    return redirect_to user_turns_url unless current_player?
    session[:ep_sessions] ||= {}
    @user = get_user

    run Turn::Operation::Create::Present, user_id: @user.id, game_id: @user.game.id do |ctx|
      return render
    end

    redirect_to user_turns_url
  end

  def create
    return redirect_to user_turns_url unless current_player?
    session[:ep_sessions] ||= {}
    @user = get_user
    existing = @user.turns.last && @user.turns.last.round == @user.game.round
    redirect_to action: "update" if existing

    run Turn::Operation::Create, user_id: @user.id, game_id: @user.game.id do |ctx|
      flash[:notice] = "Turn has been completed and saved - thank you!"
      return redirect_to user_turns_url
    end
  
    render :new
  end

  def update
    return redirect_to user_turns_url unless current_player?
    session[:ep_sessions] ||= {}
    @user = get_user
    existing = @user.turn.last && @user.turn.last.round == @user.game.round
    redirect_to action: "update" if existing

    run Turn::Operation::Update, user_id: @user.id, game_id: @user.game.id do |ctx|
      flash[:notice] = "Turn has been completed and saved - thank you!"
      return redirect_to user_turns_url
    end
  
    render :new
  end

  private

  def get_user
    User.find_by_token(params[:user_token])
  end
end
