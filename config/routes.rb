Rails.application.routes.draw do

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
