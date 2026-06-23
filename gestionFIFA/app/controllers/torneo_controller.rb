class TorneoController < ApplicationController
  def index
    @grupos = Grupo.includes(:equipos).order(:nombre)
    @seccion = params[:seccion] || "fase_grupos"
  end
end
