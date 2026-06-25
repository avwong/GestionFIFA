class EquiposController < ApplicationController
  skip_forgery_protection
  def index
    @equipos = Equipo.includes(:grupo).order(:nombre)
  end

  def create
    grupo_id = equipo_params[:grupo_id].to_i
    grupo = Grupo.find_by(id: grupo_id)

    if grupo && grupo.equipos.count >= 4
      reemplazar_id = params[:reemplazar_id].to_i
      if reemplazar_id > 0
        equipo_a_reemplazar = Equipo.find_by(id: reemplazar_id, grupo_id: grupo_id)
        if equipo_a_reemplazar
          @equipo = Equipo.new(equipo_params)
          begin
            Equipo.transaction do
              @nombre_viejo = equipo_a_reemplazar.nombre
              equipo_a_reemplazar.destroy!
              @equipo.save!
            end
            return redirect_to equipos_path, notice: "Equipo '#{@equipo.nombre}' creado correctamente, reemplazando a '#{@nombre_viejo}'."
          rescue ActiveRecord::RecordInvalid => e
            return redirect_to equipos_path, alert: "Error al crear/reemplazar el equipo: #{e.record.errors.full_messages.join(', ')}"
          end
        end
      end
      return redirect_to equipos_path, alert: "El Grupo #{grupo.nombre} está lleno. Selecciona un equipo para reemplazar."
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

    if nuevo_grupo_id != @equipo.grupo_id
      grupo_destino = Grupo.find(nuevo_grupo_id)

      if grupo_destino.equipos.count >= 4
        # Grupo lleno — intentar intercambio
        swap_id = params[:swap_id].to_i
        if swap_id > 0
          equipo_swap = Equipo.find_by(id: swap_id, grupo_id: nuevo_grupo_id)
          if equipo_swap
            grupo_origen_id = @equipo.grupo_id
            @equipo.update!(equipo_params)
            equipo_swap.update!(grupo_id: grupo_origen_id)
            return redirect_to equipos_path,
              notice: "Intercambio realizado: '#{@equipo.nombre}' → Grupo #{grupo_destino.nombre}, '#{equipo_swap.nombre}' → Grupo #{Grupo.find(grupo_origen_id).nombre}."
          end
        end
        return redirect_to equipos_path,
          alert: "El Grupo #{grupo_destino.nombre} está lleno. Selecciona un equipo para intercambiar."
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
