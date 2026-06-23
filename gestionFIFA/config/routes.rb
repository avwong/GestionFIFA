Rails.application.routes.draw do
  root "home#index"

  resources :teams
  resources :groups

  # vistas de las fases (controllers pendientes)
  get "fase-grupos",   to: "home#index", as: :fase_grupos
  get "eliminatorias", to: "home#index", as: :eliminatorias

  get "up" => "rails/health#show", as: :rails_health_check
end
