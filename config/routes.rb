Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations',
    passwords: 'users/passwords',
    confirmations: 'users/confirmations'
  }
  
  # Custom authentication endpoints
  namespace :users do
    get 'current_user', to: 'sessions#current_user_info'
    post 'refresh_token', to: 'sessions#refresh_token'
  end

  # API routes with JWT authentication
  namespace :api do
    namespace :v1 do
      resources :users, only: [] do
        collection do
          get :profile
          put :profile, to: 'users#update_profile'
          get :dashboard
          get :admin_dashboard
          get :analytics
        end
      end
      
      # Admin routes
      namespace :admin do
        resources :users, only: [:index, :show, :update, :destroy] do
          collection do
            get :export_users
          end
        end
      end
    end
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
