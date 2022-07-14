class ApplicationController < ActionController::Base
  private

  def current_user
    @_current_user ||= session[:current_user_id] &&
      User.find_by(id: session[:current_user_id])
  end

  def current_game
    current_user ? current_user.game : Game.last
  end

  def not_found
    render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
  end
end
