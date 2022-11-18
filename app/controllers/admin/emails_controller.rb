module Admin
  class EmailsController < ApplicationController
    layout "admin"

    unless Rails.env.test?
      http_basic_authenticate_with name: Rails.configuration.admin_name, password: Rails.configuration.admin_password
    end
  
    def new
      @game = Game.find(params[:game_id])
      run Email::Operation::Create::Present do |ctx|
        @form = ctx["contract.default"]
        render
      end
    end
  
    def create
      @game = Game.find(params[:game_id])
      _ctx = run Email::Operation::Create do |ctx|
        flash[:notice] = "Email was sent for '#{@game.name}'"
        return redirect_to admin_games_url
      end
    
      @form = _ctx["contract.default"]
      render :new, status: :unprocessable_entity
    end
  end
end