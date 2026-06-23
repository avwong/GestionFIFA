class EquiposController < ApplicationController
  def index
    @equipos = Equipo.includes(:grupo).order(:nombre)
  end
end
