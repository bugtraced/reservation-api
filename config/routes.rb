Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      resources :customers do
        resources :vehicles, only: [ :index, :create ]
        resources :reservations, only: [ :index, :create ]
      end
      resources :vehicles
      resources :reservations
    end
  end
end
