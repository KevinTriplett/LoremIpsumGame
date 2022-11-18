class Admin::UsersController < ApplicationController
  layout "admin"

  unless Rails.env.test?
    http_basic_authenticate_with name: Rails.configuration.admin_name, password: Rails.configuration.admin_password
  end

  def index
    run User::Operation::Index do |ctx|
      @model = ctx[:model]
      @game = ctx[:game]
      render
    end  
  end

  def new
    @game = get_game
    run User::Operation::Create::Present, game_id: @game.id do |ctx|
      @form = ctx["contract.default"]
      render
    end
  end

  def create
    @game = get_game
    _ctx = run User::Operation::Create, game_id: @game.id do |ctx|
      flash[:notice] = "#{ctx[:model].name} was created"
      return redirect_to new_admin_game_user_url
    end

    @form = _ctx["contract.default"]
    render :new, status: :unprocessable_entity
  end

  def edit
    run User::Operation::Update::Present do |ctx|
      @form = ctx["contract.default"]
      render
    end
  end

  def update
    _ctx = run User::Operation::Update do |ctx|
      flash[:notice] = "#{ctx[:model].name} was updated"
      return redirect_to admin_game_users_url(ctx[:model].game_id)
    end
  
    @form   = _ctx["contract.default"] # FIXME: redundant to #create!
    render :edit, status: :unprocessable_entity
  end

  def destroy
    run User::Operation::Delete do
      flash[:notice] = "User deleted"
      return redirect_to admin_game_users_url, status: 303
    end
  
    flash[:error] = "Unable to delete User"
    return redirect_to admin_game_users_url(game_id: params[:game_id]), status: :unprocessable_entity
  end

  private

  def get_game
    Game.find(params[:game_id])
  end
end
