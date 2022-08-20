Rails.application.routes.draw do

  post "/admin/game(/:id)/toggle_end", to: "admin/games#toggle_end", as: :toggle_end_admin_game

  resources :admin, only: [:index]

  namespace :admin do 
    resources :games do
      resources :users
    end
  end

  resources :users, param: :token, only: [:show] do
    resources :turns, only: [:index, :new, :create, :update]
  end

  # Defines the root path route ("/")
  root to: "users#show"
end
