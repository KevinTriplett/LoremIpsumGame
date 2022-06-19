class TurnsController < ApplicationController
  def new
    run Turn::Operation::Create::Present do |ctx|
      @form = ctx["contract.default"]
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
