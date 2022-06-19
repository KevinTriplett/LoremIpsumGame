class GamesController < ApplicationController
  def show
    session[:current_user_id] = params[:user_id] if params[:user_id]
    # TODO: handle current_user = nil
    @game = Game.find(current_user.game_id)
    redirect_to new_users_path if @game && !@game.users.present?
    redirect_to new_turns_path if @game && @game.current_player_id = current_user.id
  end
  
  def new
    run Game::Operation::Create::Present do |ctx|
      @form = ctx["contract.default"]
      render
    end
  end

  def create
    _ctx = run Game::Operation::Create do |ctx|
      return redirect_to new_user_path
    end
  
    @form = _ctx["result.contract.default"]
    render :new
  end
end