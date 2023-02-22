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
      resources :attendances, only: [:new, :create, :show]
      resources :students

      get '/slack/new', to: 'slack#new', as: :slack_integration
      post '/slack', to: 'slack#create'
      patch '/slack_channel_import', to: "slack#connect_accounts"

      get '/populi/new', to: 'populi#new', as: :populi_integration
      get '/populi/courses/:course_id', to: 'populi#match_students', as: :populi_match_students
      post '/populi', to: 'populi#create'
    end
  end
end
