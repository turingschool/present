Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'user/dashboard#show'
  get '/welcome', to: 'welcome#index'
  get '/auth/google_oauth2/callback', to: 'sessions#create'
  delete '/sessions', to: 'sessions#destroy'

  scope module: :user do
    resources :users, only: [:update]
    resources :innings, only: [:show, :create, :index, :update]
    resources :turing_modules, path: '/modules', only: [:show, :create], shallow: true do
      resources :attendances, only: [:new, :create, :show]
      resources :students
    end
  end
end
