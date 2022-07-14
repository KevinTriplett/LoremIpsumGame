class GamesController < ApplicationController
  def show
    session[:current_user_id] = params[:user_id] if params[:user_id]
    # TODO: handle current_user = nil
    if current_user
      @game = Game.find(current_user.game_id)
      return redirect_to new_game_path unless @game
      return redirect_to new_user_path if @game && !@game.users.present?
      return redirect_to new_turn_path if @game && @game.current_player_id = current_user.id
    else
      @game = Game.last
      return redirect_to new_game_path unless @game
    end
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