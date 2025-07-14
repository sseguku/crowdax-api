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
      # Public endpoints
      namespace :public do
        get :campaigns, to: '/api/v1/public#campaigns'
        get :statistics, to: '/api/v1/public#statistics'
        get :metadata, to: '/api/v1/public#metadata'
      end
      
      resources :users, only: [] do
        collection do
          get :profile
          put :profile, to: 'users#update_profile'
          get :dashboard
          get :admin_dashboard
          get :analytics
          # Consent endpoints
          get :consent, to: 'users#consent'
          post :consent, to: 'users#give_consent'
          delete :consent, to: 'users#withdraw_consent'
          # Data Subject Rights endpoints
          get :data, to: 'users#data_subject_data'
          put :data, to: 'users#update_data_subject_data'
          delete :data, to: 'users#request_data_deletion'
          get 'data/export', to: 'users#export_data'
        end
      end
      
      # KYC routes
      resources :kycs, only: [:index, :show, :create, :update, :destroy] do
        member do
          post :approve
        end
        resources :documents, only: [:show], controller: 'secure_documents'
      end
      
      # Campaign routes
      resources :campaigns, only: [:index, :show, :create, :update, :destroy] do
        resources :documents, only: [:show], controller: 'document_downloads'
      end
      
      # Admin routes
      namespace :admin do
        # Dashboard
        get 'dashboard', to: 'dashboard#index'
        
        # Breach management
        resources :breaches, only: [:index, :show, :update] do
          member do
            post :resolve
            post :mark_false_positive
          end
          collection do
            get :summary
            post :test, to: 'breaches#test_breach_detection'
          end
        end
        
        # Entrepreneurs management
        resources :entrepreneurs, only: [:index, :show] do
          member do
            post :approve
            post :reject
            post :deactivate
          end
        end
        
        # Investors management
        resources :investors, only: [:index, :show] do
          member do
            post :approve
            post :reject
          end
        end
        
        # Campaigns management
        resources :campaigns, only: [:index, :show] do
          member do
            post :approve
            post :reject
          end
        end
        
        # KYC management
        resources :kycs, only: [:index, :show] do
          member do
            post :approve
            post :reject
            post :request_revision
          end
        end
        
        # Users management (existing)
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
