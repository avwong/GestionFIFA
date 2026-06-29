class EquiposController < ApplicationController
  skip_forgery_protection
  before_action :load_torneo

  def index
    @equipos = @torneo.equipos.includes(:grupo).order(:nombre)
  end

  def create
    grupo_id = equipo_params[:grupo_id].to_i
    grupo = @torneo.grupos.find_by(id: grupo_id)

    return redirect_to torneo_equipos_path(@torneo), alert: 'Grupo no válido para este torneo.' unless grupo

    if grupo.equipos.count >= 4
      reemplazar_id = params[:reemplazar_id].to_i

      if reemplazar_id > 0
        equipo_a_reemplazar = grupo.equipos.find_by(id: reemplazar_id)

        if equipo_a_reemplazar
          @equipo = Equipo.new(equipo_params)

          begin
            Equipo.transaction do
              @nombre_viejo = equipo_a_reemplazar.nombre

              grupo.limpiar_partidos_de_equipo(equipo_a_reemplazar.id)
              equipo_a_reemplazar.destroy!
              @equipo.save!

              grupo.recalcular_estadisticas
            end

            return redirect_to torneo_equipos_path(@torneo),
                               notice: "Equipo '#{@equipo.nombre}' creado correctamente, reemplazando a '#{@nombre_viejo}'."
          rescue ActiveRecord::RecordInvalid => e
            return redirect_to torneo_equipos_path(@torneo),
                               alert: "Error al crear/reemplazar el equipo: #{e.record.errors.full_messages.join(', ')}"
          end
        end
      end

      return redirect_to torneo_equipos_path(@torneo),
                         alert: "El Grupo #{grupo.nombre} está lleno. Selecciona un equipo para reemplazar."
    end

    @equipo = Equipo.new(equipo_params)

    if @equipo.save
      redirect_to torneo_equipos_path(@torneo), notice: "Equipo '#{@equipo.nombre}' creado correctamente."
    else
      redirect_to torneo_equipos_path(@torneo),
                  alert: "Error al crear el equipo: #{@equipo.errors.full_messages.join(', ')}"
    end
  end

  def update
    @equipo = @torneo.equipos.find(params[:id])
    grupo_origen = @equipo.grupo
    nuevo_grupo_id = equipo_params[:grupo_id].to_i

    if nuevo_grupo_id != @equipo.grupo_id
      grupo_destino = @torneo.grupos.find(nuevo_grupo_id)

      if grupo_destino.equipos.count >= 4
        swap_id = params[:swap_id].to_i

        if swap_id > 0
          equipo_swap = grupo_destino.equipos.find_by(id: swap_id)

          if equipo_swap
            begin
              Equipo.transaction do
                grupo_origen.limpiar_partidos_de_equipo(@equipo.id)
                grupo_destino.limpiar_partidos_de_equipo(equipo_swap.id)

                @equipo.update!(equipo_params)
                equipo_swap.update!(grupo_id: grupo_origen.id)

                grupo_origen.recalcular_estadisticas
                grupo_destino.recalcular_estadisticas
              end

              return redirect_to torneo_equipos_path(@torneo),
                                 notice: 'Intercambio realizado correctamente.'
            rescue ActiveRecord::RecordInvalid => e
              return redirect_to torneo_equipos_path(@torneo),
                                 alert: "Error al intercambiar equipos: #{e.record.errors.full_messages.join(', ')}"
            end
          end
        end

        return redirect_to torneo_equipos_path(@torneo),
                           alert: "El Grupo #{grupo_destino.nombre} está lleno. Selecciona un equipo para intercambiar."
      end

      begin
        Equipo.transaction do
          grupo_origen.limpiar_partidos_de_equipo(@equipo.id)
          @equipo.update!(equipo_params)

          grupo_origen.recalcular_estadisticas
          grupo_destino.recalcular_estadisticas
        end

        return redirect_to torneo_equipos_path(@torneo),
                           notice: "Equipo '#{@equipo.nombre}' actualizado correctamente."
      rescue ActiveRecord::RecordInvalid => e
        return redirect_to torneo_equipos_path(@torneo),
                           alert: "Error al actualizar el equipo: #{e.record.errors.full_messages.join(', ')}"
      end
    end

    if @equipo.update(equipo_params)
      redirect_to torneo_equipos_path(@torneo), notice: "Equipo '#{@equipo.nombre}' actualizado correctamente."
    else
      redirect_to torneo_equipos_path(@torneo),
                  alert: "Error al actualizar el equipo: #{@equipo.errors.full_messages.join(', ')}"
    end
  end

  def destroy
    @equipo = @torneo.equipos.find(params[:id])
    grupo = @equipo.grupo
    nombre = @equipo.nombre

    Equipo.transaction do
      grupo.limpiar_partidos_de_equipo(@equipo.id)
      @equipo.destroy!
      grupo.recalcular_estadisticas
    end

    redirect_to torneo_equipos_path(@torneo), notice: "Equipo '#{nombre}' borrado correctamente."
  end

  private

  def load_torneo
    @torneo = Torneo.find(params[:torneo_id])
  end

  def equipo_params
    params.require(:equipo).permit(:nombre, :grupo_id)
  end
end
