class Admin::UsersController < ApplicationController
  def index
    run User::Operation::Index do |ctx|
      @model = ctx[:model]
      @game = ctx[:game]
      render
    end  
  end

  def new
    puts "params[:game_id] = " + params[:game_id]
    run User::Operation::Create::Present, game_id: params[:game_id] do |ctx|
      @form = ctx["contract.default"]
      @game = ctx[:game]
      puts "@game = " + @game.inspect
      render
    end
  end

  def create
    _ctx = run User::Operation::Create, game_id: params[:game_id] do |ctx|
      return redirect_to new_user_path
    end
  
    @form = _ctx["contract.default"]
    render :new
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
    render :edit
  end
end
