Rails.application.routes.draw do

  post "/admin/games(/:id)/end", to: "admin/games#toggle_end", as: :end_admin_game
  post "/admin/games(/:id)/resume", to: "admin/games#resume", as: :resume_admin_game
  get "/users(/:token)/turns/diff", to: "turns#diff", as: :user_turns_diff

  resources :admin, only: [:index]

  namespace :admin do 
    resources :games do
      resources :users
    end
  end

  resources :users, param: :token, only: [:show] do
    resources :turns, only: [:index, :new, :create]
  end

  # Defines the root path route ("/")
  root to: "users#show"
end
