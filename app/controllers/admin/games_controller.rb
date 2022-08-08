module Admin
  class GamesController < ApplicationController
    unless Rails.env.test?
      http_basic_authenticate_with name: Rails.configuration.admin_name, password: Rails.configuration.admin_password
    end
  
    def index
      @games = Game.all
    end
    
    def new
      run Game::Operation::Create::Present do |ctx|
        @form = ctx["contract.default"]
        get_defaults
        render
      end
    end
  
    def create
      _ctx = run Game::Operation::Create do |ctx|
        return redirect_to new_admin_game_user_url(game_id: ctx[:model].id)
      end
    
      @form = _ctx["contract.default"]
      get_defaults
      render :new, status: :unprocessable_entity
    end
  
    def edit
      run Game::Operation::Update::Present do |ctx|
        @form = ctx["contract.default"]
        get_defaults
        render
      end
    end
  
    def update
      _ctx = run Game::Operation::Update do |ctx|
        flash[:notice] = "#{ctx[:model].name} has been saved"
        return redirect_to admin_games_url
      end
    
      @form = _ctx["contract.default"] # FIXME: redundant to #create!
      get_defaults
      render :edit, status: :unprocessable_entity
    end

    def destroy
      run Game::Operation::Delete do |ctx|
        flash[:notice] = "Game deleted"
        return redirect_to admin_games_url
      end

      flash[:notice] = "Unable to delete Game"
    end

    private

    def get_defaults
      @default_game_days = Rails.configuration.default_game_days
      @default_turn_hours = Rails.configuration.default_turn_hours
    end
  end
end