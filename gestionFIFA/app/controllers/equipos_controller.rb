class EquiposController < ApplicationController
  def index
    @equipos = Equipo.includes(:grupo).order(:nombre)
  end

  def update
    @equipo = Equipo.find(params[:id])

    if @equipo.update(equipo_params)
      redirect_to equipos_path, notice: "Equipo '#{@equipo.nombre}' actualizado correctamente."
    else
      redirect_to equipos_path, alert: "Error al actualizar el equipo: #{@equipo.errors.full_messages.join(', ')}"
    end
  end

  private

  def equipo_params
    params.require(:equipo).permit(
      :nombre,
      :grupo_id,
      :puntos,
      :partidos_jugados,
      :partidos_ganados,
      :partidos_empatados,
      :partidos_perdidos,
      :goles_favor,
      :goles_contra
    )
  end
end
