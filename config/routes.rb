Rails.application.routes.draw do
  get "home/index"
  root "home#index"
  get "reviews/create"
  get "reviews/index"
  get "bookings/create"
  get "bookings/update"
  get "bookings/index"
  get 'listings/rentals/:id', to: 'listings#single_listing'
  get 'listings/homepage_featured', to: 'listings#homepage_featured'
  get 'listings/homepage_city_listings', to: 'listings#homepage_city_listings'
  resources :favorites, only: [:index, :create, :destroy], param: :listing_id
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  post '/login', to: 'auth#login'
  get '/profile', to: 'users#profile'


  # Defines the root path route ("/")
  # root "posts#index"
end
