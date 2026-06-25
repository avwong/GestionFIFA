class EquiposController < ApplicationController
  skip_forgery_protection
  def index
    @equipos = Equipo.includes(:grupo).order(:nombre)
  end

  def create
    grupo_id = equipo_params[:grupo_id].to_i
    grupo = Grupo.find_by(id: grupo_id)

    if grupo && grupo.equipos.count >= 4
      return redirect_to equipos_path, alert: "El Grupo #{grupo.nombre} ya tiene 4 equipos. No se puede añadir más."
    end

    @equipo = Equipo.new(equipo_params)
    if @equipo.save
      redirect_to equipos_path, notice: "Equipo '#{@equipo.nombre}' creado correctamente."
    else
      redirect_to equipos_path, alert: "Error al crear el equipo: #{@equipo.errors.full_messages.join(', ')}"
    end
  end

  def update
    @equipo = Equipo.find(params[:id])
    nuevo_grupo_id = equipo_params[:grupo_id].to_i

    # Verificar si el grupo destino ya tiene 4 equipos (y es diferente al actual)
    if nuevo_grupo_id != @equipo.grupo_id
      grupo_destino = Grupo.find(nuevo_grupo_id)
      if grupo_destino.equipos.count >= 4
        return redirect_to equipos_path,
          alert: "El Grupo #{grupo_destino.nombre} ya tiene 4 equipos. No se puede agregar más."
      end
    end

    if @equipo.update(equipo_params)
      redirect_to equipos_path, notice: "Equipo '#{@equipo.nombre}' actualizado correctamente."
    else
      redirect_to equipos_path, alert: "Error al actualizar el equipo: #{@equipo.errors.full_messages.join(', ')}"
    end
  end

  def destroy
    @equipo = Equipo.find(params[:id])
    nombre = @equipo.nombre
    @equipo.destroy
    redirect_to equipos_path, notice: "Equipo '#{nombre}' borrado correctamente."
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
