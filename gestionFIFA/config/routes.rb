Rails.application.routes.draw do
  root "equipos#index"

  get "equipos", to: "equipos#index", as: :equipos
  get "torneo",  to: "torneo#index",  as: :torneo

  get "en-desarrollo", to: "home#coming_soon", as: :coming_soon

  get "up" => "rails/health#show", as: :rails_health_check
end
