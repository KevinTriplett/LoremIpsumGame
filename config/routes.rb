Rails.application.routes.draw do
  namespace :admin do
    resource :game, only: [:new, :create, :edit] do
      resources :users, only: [:new, :create]
    end
  end

  resource :game, only: [:edit] do
    resources :turns, only: [:create]
  end

  # Defines the root path route ("/")
  root to: "game#edit"
end
