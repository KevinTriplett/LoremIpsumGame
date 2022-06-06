module Admin
  class GamesController < ApplicationController
    def new
      @form = GameForm.new(Game.new)
    end

    def create
    end

    def edit
      @form = GameForm.new(Game.last)
    end
  end
end