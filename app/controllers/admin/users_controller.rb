class Admin::UsersController < ApplicationController
  def index
    run User::Operation::Index do |ctx|
      @model = ctx[:model]
      @game = ctx[:game]
      render
    end  
  end

  def new
    run User::Operation::Create::Present, game_id: params[:game_id] do |ctx|
      @form = ctx["contract.default"]
      @game = Game.find(params[:game_id])
      render
    end
  end

  def create
    _ctx = run User::Operation::Create, game_id: params[:game_id] do |ctx|
      return redirect_to new_admin_game_user_path
    end
  
    puts "result = " + _ctx.inspect
    @form = _ctx["contract.default"]
    @game = Game.find(params[:game_id])
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
      flash[:notice] = "#{ctx[:model].name} has been saved"
      return redirect_to admin_game_users_path(ctx[:model].game_id)
    end
  
    @form   = _ctx["contract.default"] # FIXME: redundant to #create!
    render :edit, status: :unprocessable_entity
  end

  def destroy
    run User::Operation::Delete
  
    flash[:notice] = "User deleted"
    redirect_to admin_game_users_path #(game_id: params[:game_id])
  end
end
