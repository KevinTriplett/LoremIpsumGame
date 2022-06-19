Rails.application.routes.draw do

  resource :games, only: [:show, :new, :create]
  resources :users, only: [:new, :create]
  resources :turns, only: [:new, :create]

  # Defines the root path route ("/")
  root to: "games#show"
end
