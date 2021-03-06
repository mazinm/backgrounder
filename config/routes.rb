Backgrounder::Application.routes.draw do
  root to: 'pages#index'
  
  get "/pages/about" => 'pages#about', :as => 'about'
  
  get "/sessions/gettweets" => 'sessions#gettweets', :as => 'tweets'
  get "/sessions/findhashtags" => 'sessions#findhashtags', :as => 'hashtags'
  get "/sessions/providebackground" => 'sessions#providebackground', :as => 'backgrounder'
   
  resources :users, :only => [:index, :show, :edit, :update ]
  get '/auth/:provider/callback' => 'sessions#create'
  get '/signin' => 'sessions#new', :as => :signin
  get '/signout' => 'sessions#destroy', :as => :signout
  get '/auth/failure' => 'sessions#failure'
end
