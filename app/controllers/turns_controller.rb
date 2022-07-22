class TurnsController < ApplicationController
  def show
    ether = EtherpadLite.connect(9001, File.new('/srv/www/etherpad-lite/APIKEY.txt'))
    render
  end

  def new
    return redirect_to :show unless current_user_turn?
    session[:ep_sessions] ||= {}
    user = User.find_by_token(params[:user_token])
    run Turn::Operation::Create::Present, user_id: user.id do |ctx|
      @turn = ctx["contract.default"]
      @game = current_game
      # see https://github.com/ether/etherpad-lite/issues/3750
      render
    end
  end

  def create
    _ctx = run Turn::Operation::Create do |ctx|
      return redirect_to show_games_path
    end
  
    @form = _ctx["contract.default"]
    render :new
  end
end
