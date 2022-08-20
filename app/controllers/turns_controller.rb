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
    @user = get_user
    return user_turns_url if @user.game.ended? || !current_player?
    @existing_turn = @user.turns.where(round: @user.game.round).first
    return redirect_to user_turn_url(id: @existing_turn.id) if @existing_turn

    run Turn::Operation::Create, user_id: @user.id, game_id: @user.game.id do |ctx|
      flash[:notice] = "Turn has been completed and saved - thank you!"
      return redirect_to user_turns_url
    end
  
    render :new
  end

  def update
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
