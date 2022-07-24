class TurnsController < ApplicationController
  def index
    client = EtherpadLite.client(9001, Rails.configuration.etherpad_api_key)
    @game = User.find_by_token(params[:user_token]).game
    pad_name = @game.name.gsub(/\s/, '_')
    @story = Rails.env == "test" ? "test story" : client.getText(padID: pad_name)[:text]
    render
  end

  def new
    return redirect_to user_turns_path unless current_user_turn?
    session[:ep_sessions] ||= {}
    user = User.find_by_token(params[:user_token])

    run Turn::Operation::Create::Present, user_id: user.id do |ctx|
      @user = User.find( ctx["contract.default"].user_id )
      @game = current_game
      # see https://github.com/ether/etherpad-lite/issues/3750
      render
    end
  end

  def create
    return redirect_to :show unless current_user_turn?
    session[:ep_sessions] ||= {}
    user = User.find_by_token(params[:user_token])

    _ctx = run Turn::Operation::Create, user_id: user.id do |ctx|
      flash[:notice] = "Turn has been saved and completed - thank you!"
      return redirect_to user_turns_path
    end
  
    @turn = _ctx["contract.default"]
    @game = current_game
    render :new
  end
end
