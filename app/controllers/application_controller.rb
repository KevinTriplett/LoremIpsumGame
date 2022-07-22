class ApplicationController < ActionController::Base
  private

  def current_user
    @_current_user = User.find_by_token(params[:token])
    session[:current_user_id] = @_current_user.id if @_current_user

    @_current_user ||= session[:current_user_id] &&
      User.find_by(id: session[:current_user_id])
  end

  def current_game
    current_user ? current_user.game : nil
  end

  def current_user_turn?
    current_user && current_game && current_user.id == current_game.current_player_id
  end

  def not_found
    render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
  end
end
