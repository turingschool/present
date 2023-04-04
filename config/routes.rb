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
      resources :attendances, only: [:new, :create, :show, :edit, :update] do
        get "populi_transfer", to: "populi_transfer#new"
        patch "students/:id", to: 'attendances#save_zoom_alias', as: :student
      end

      resources :students

      get '/slack/new', to: 'slack#new', as: :slack_integration
      post '/slack', to: 'slack#create'

      get '/zoom/new', to: 'zoom#new', as: :zoom_integration

      get '/account_match', to: 'account_match#new'
      post '/account_match', to: 'account_match#create'

      get '/populi/new', to: 'populi#new', as: :populi_integration
      get '/populi/courses/:course_id', to: 'populi#match_students', as: :populi_match_students
      post '/populi', to: 'populi#create'
    end
  end
end
