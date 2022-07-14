module Admin
  class GamesController < ApplicationController
    def index
      @games = Game.all
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
  
    def edit
      @form = GameForm.find(params[:game_id])
    end

    def update
      _ctx = run Game::Operation::Update do |ctx|
        return redirect_to admin_game_path
      end
    
      @form = _ctx["result.contract.default"]
      render :edit      
    end
  end
end