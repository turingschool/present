Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'user/dashboard#show'
  get '/welcome', to: 'welcome#index'
  get '/auth/google_oauth2/callback', to: 'sessions#create'
  delete '/sessions', to: 'sessions#destroy'

  scope module: :user do
    resources :users, only: [:update]
    resources :innings, only: [:show]
    resources :turing_modules, path: '/modules', only: [:show, :create], shallow: true do
      resources :attendances, only: [:create, :show, :edit, :update] do
        resources :populi_transfer, only: [:new, :create, :index]
        patch "students/:id", to: 'attendances#save_zoom_alias', as: :student
      end

      resources :students

      get '/slack/new', to: 'slack#new', as: :slack_integration
      post '/slack', to: 'slack#create'

      get '/zoom/new', to: 'zoom#new', as: :zoom_integration

      resources :account_match, only: [:new, :create]

      get '/populi/new', to: 'populi#new', as: :populi_integration
      get '/populi/courses/:course_id', to: 'populi#match_students', as: :populi_match_students
      post '/populi', to: 'populi#create'
      patch '/populi', to: 'populi#update'
    end
  end
end
