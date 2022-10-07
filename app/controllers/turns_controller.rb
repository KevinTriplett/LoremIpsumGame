class TurnsController < ApplicationController
  def index
    @user = get_user
    render
  end

  def new
    @user = get_user
    return redirect_to user_turns_url if !current_player? || @user.game.paused?

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

  def diff
    @user = get_user
    @user_last_turn = @user.turns.order(id: :asc).last
    @game_last_turn = @user.game.turns.order(id: :asc).last
    return render unless @user_last_turn && @game_last_turn &&
      @user_last_turn.revision == @game_last_turn.revision

    flash[:notice] = "No changes made since your last turn"
    return redirect_to new_user_turn_url(user_token: @user.token)
  end

  private

  def get_user
    User.find_by_token(params[:user_token])
  end
end
