class UsersController < ApplicationController
  def show
    # game is entered through /users/<user_token>/turns/new
    return not_found
  end
end
