class TorneoController < ApplicationController
  def index
    @grupos  = Grupo.includes(:equipos).order(:nombre)
    @seccion = params[:seccion] || "fase_grupos"
    cargar_podio if @seccion == "podio"
  end

  private

  def cargar_podio
    podio    = Partido.podio
    @primero = podio[:primero]
    @segundo = podio[:segundo]
    @tercero = podio[:tercero]
  end
end
