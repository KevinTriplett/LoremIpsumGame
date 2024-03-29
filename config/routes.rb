Rails.application.routes.draw do

  post "/admin/games(/:id)/end", to: "admin/games#toggle_ended", as: :toggle_ended_admin_game
  post "/admin/games(/:id)/resume", to: "admin/games#toggle_paused", as: :toggle_paused_admin_game
  get "/users(/:token)/turns/diff", to: "turns#diff", as: :user_turns_diff
  get "/users(/:token)/unsubscribe", to: "users#unsubscribe", as: :user_unsubscribe
  post "/users(/:token)/padtoken", to: "users#pad_token", as: :user_pad_token

  resources :admin, only: [:index]

  namespace :admin do
    resources :games do
      resources :users, param: :token
      resources :emails, only: [:new, :create]
    end
  end

  resources :users, param: :token, only: [:show, :destroy] do
    resources :turns, only: [:index, :new, :create]
  end

  # Defines the root path route ("/")
  # game is normally entered through /users(/:user_token)/turns/new
  root to: "users#index"
end
