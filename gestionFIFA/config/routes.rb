Rails.application.routes.draw do
  root "equipos#index"

  get   "equipos",      to: "equipos#index",  as: :equipos
  patch "equipos/:id",  to: "equipos#update", as: :equipo
  get   "torneo",       to: "torneo#index",   as: :torneo

  get "en-desarrollo", to: "home#coming_soon", as: :coming_soon

  get "up" => "rails/health#show", as: :rails_health_check
end
