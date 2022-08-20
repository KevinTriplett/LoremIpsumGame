class ApplicationController < ActionController::Base
  private

  def current_user
    session[:ep_sessions] ||= {}
    session[:user_token] = params[:user_token] if params[:user_token]
    User.find_by_token( session[:user_token] )
  end

  def current_game
    current_user.game
  end

  def current_player?
    current_user.id == current_game.current_player_id
  end

  def not_found
    render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
  end
end
