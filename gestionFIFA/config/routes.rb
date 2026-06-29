Rails.application.routes.draw do
  root 'torneos#index'

  resources :torneos, only: %i[index new create show edit update destroy] do
    member do
      post :generar_partidos_grupos
      patch :guardar_partidos_grupo
      post :generar_bracket
      patch :guardar_partido_eliminacion
    end

    resources :equipos, only: %i[index create update destroy]
  end

  get 'en-desarrollo', to: 'home#coming_soon', as: :coming_soon

  get 'up' => 'rails/health#show', as: :rails_health_check
end
