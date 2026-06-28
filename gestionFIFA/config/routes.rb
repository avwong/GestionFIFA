Rails.application.routes.draw do
  root "torneos#index"

  resources :torneos, only: [:index, :new, :create, :show, :edit, :update, :destroy] do
    resources :equipos, only: [:index, :create, :update, :destroy]
  end

  get "en-desarrollo", to: "home#coming_soon", as: :coming_soon

  get "up" => "rails/health#show", as: :rails_health_check
end
