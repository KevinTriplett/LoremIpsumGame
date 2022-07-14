class AdminController < ApplicationController
    def index
      redirect_to admin_games_path
    end
end