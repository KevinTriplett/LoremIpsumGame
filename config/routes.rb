Rails.application.routes.draw do

  resources :games, only: [:show, :new, :create, :edit, :delete]
  resources :users, only: [:new, :create]
  resources :turns, only: [:new, :create]
  resources :admin, only: [:index]

  # Defines the root path route ("/")
  root to: "games#show"
end
