class AdminController < ApplicationController
    def index
      @games = Game.all
      render
    end
end