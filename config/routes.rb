Rails.application.routes.draw do

  resources :admin, only: [:index]

  namespace :admin do 
    resources :games do
      resources :users
    end
  end

  resources :users, only: [:show]

  resources :games, only: [:show] do
    namespace :users do
      resources :turns, only: [:new, :create]
    end
  end

  # Defines the root path route ("/")
  root to: "games#show"
end
