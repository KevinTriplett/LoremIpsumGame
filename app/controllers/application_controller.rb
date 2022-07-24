class ApplicationController < ActionController::Base
  private

  def current_user
    User.find_by_token(params[:user_token])
  end

  def current_game
    current_user.game
  end

  def current_user_turn?
    current_user.id == current_game.current_player_id
  end

  def not_found
    render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
  end
end
