class AdminController < ApplicationController
  http_basic_authenticate_with name: Rails.configuration.admin_name, password: Rails.configuration.admin_password

  def index
    redirect_to admin_games_url
  end
end