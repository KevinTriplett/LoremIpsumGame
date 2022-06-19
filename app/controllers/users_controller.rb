class UsersController < ApplicationController
  def new
    run User::Operation::Create::Present do |ctx|
      @form = ctx["contract.default"]
      render
    end
  end

  def create
    _ctx = run User::Operation::Create do |ctx|
      return redirect_to new_user_path
    end
  
    @form = _ctx["contract.default"]
    render :new
  end
end
