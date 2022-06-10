Rails.application.routes.draw do

  resource :game, only: [:new, :create] do
  resources :users, only: [:new, :create]
  resources :turns, only: [:create]

  # Defines the root path route ("/")
  root to: "turns#create"
end
