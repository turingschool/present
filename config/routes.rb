Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'user/dashboard#show'
  get '/welcome', to: 'welcome#index'
  get '/auth/google_oauth2/callback', to: 'sessions#create'
  delete '/sessions', to: 'sessions#destroy'
  get '/help', to: 'welcome#help'
  
  scope module: :user do
    resources :users, only: [:update]
    resources :innings, only: [:show, :create, :index, :update]
    resources :turing_modules, path: '/modules', only: [:show, :create], shallow: true do
      get '/slack_channel_import', to: "slack#new"
      post '/slack_channel_import', to: "slack#import_students"
      resources :attendances, only: [:new, :create, :show]
      resources :students
    end
  end
end
