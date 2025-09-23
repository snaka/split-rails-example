Rails.application.routes.draw do
  root "todos#index"

  resources :users, only: [:new, :create]
  resources :sessions, only: [:new, :create, :destroy]
  resources :todos

  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"
  get "signup", to: "users#new"

  # Public pages for A/B testing
  get "about", to: "public#about"
  get "features", to: "public#features"
  get "pricing", to: "public#pricing"
  get "contact", to: "public#contact"
  get "help", to: "public#help"
  get "demo", to: "public#demo"
  post "demo/action", to: "public#demo_action"
  post "contact", to: "public#contact_submit"

  # Split dashboard
  mount Split::Dashboard, at: "split"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
