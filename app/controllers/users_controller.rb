class UsersController < ApplicationController
  def show
    # game is entered through /users(/:user_token)/turns/new
    render :file => "#{Rails.root}/public/puppy.html", :layout => false
  end
end
