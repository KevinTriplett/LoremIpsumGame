Rails.application.routes.draw do

  resource :game, only: [:new, :create]
  resources :users, only: [:new, :create]
  resources :turns, only: [:create]

  # Defines the root path route ("/")
  root to: "game#show"
end
