Rails.application.routes.draw do
  root 'static_pages#home'

  get    'help' => 'static_pages#help'
  get    'about' => 'static_pages#about'
  get    'contact' => 'static_pages#contact'
  get    'signup' => 'users#new'
  get    '/login',   to: 'sessions#new'
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  # get '/logout', to: 'sessions#destroy'
  delete '/logout', to: 'sessions#destroy'

  resources :users do
    member do
      get :following, :followers
    end
  end

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  resources :account_activations,    only: [:edit]
  resources :password_resets,        only: %i[new create edit update]
  resources :microposts,             only: %i[create destroy]
  resources :relationships, only: %i[create destroy]
end
