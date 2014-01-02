Backgrounder::Application.routes.draw do
  root to: 'pages#index'
  
  get "/sessions" => 'sessions#gettweets', :as => 'Tweets'
   
  resources :users, :only => [:index, :show, :edit, :update ]
  get '/auth/:provider/callback' => 'sessions#create'
  get '/signin' => 'sessions#new', :as => :signin
  get '/signout' => 'sessions#destroy', :as => :signout
  get '/auth/failure' => 'sessions#failure'
end
