class TorneosController < ApplicationController
  before_action :load_torneo, only: %i[show edit update destroy generar_partidos_grupos guardar_partidos_grupo]

  def index
    @torneos = Torneo.order(:nombre)
  end

  def new
    @torneo = Torneo.new
  end

  def create
    @torneo = Torneo.new(torneo_params)

    begin
      Torneo.transaction do
        @torneo.save!
        crear_grupos_iniciales(@torneo)
      end

      redirect_to torneo_path(@torneo), notice: "Torneo '#{@torneo.nombre}' creado correctamente."
    rescue ActiveRecord::RecordInvalid => e
      redirect_to torneos_path, alert: "Error al crear el torneo: #{e.record.errors.full_messages.join(', ')}"
    rescue ActiveRecord::RecordNotUnique
      redirect_to torneos_path, alert: 'Error al crear el torneo: ya existen datos repetidos.'
    end
  end

  def show
    @seccion = params[:seccion] || 'fase_grupos'
    @grupos = @torneo.grupos.includes(:equipos, partidos: %i[equipo_local equipo_visitante]).order(:nombre)
    @mejores_terceros_ids = @torneo.mejores_terceros.map(&:id)

    cargar_podio if @seccion == 'podio'
    cargar_clasificados if @seccion == 'clasificados'
  end

  def edit
  end

  def update
    if @torneo.update(torneo_params)
      redirect_to edit_torneo_path(@torneo), notice: 'Torneo actualizado correctamente.'
    else
      flash.now[:alert] = @torneo.errors.full_messages.join(', ')
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    nombre = @torneo.nombre
    @torneo.destroy
    redirect_to torneos_path, notice: "Torneo '#{nombre}' eliminado."
  end

  def generar_partidos_grupos
    grupos_generados = 0

    @torneo.grupos.includes(:equipos).each do |grupo|
      next if grupo.equipos.count < 2

      antes = grupo.partidos.where(fase: 'fase_grupos').count
      grupo.generar_partidos_fase_grupos
      despues = grupo.partidos.where(fase: 'fase_grupos').count

      grupos_generados += 1 if despues > antes
    end

    if grupos_generados > 0
      @torneo.update(estado: 'grupos') if @torneo.estado == 'configuracion'

      redirect_to torneo_path(@torneo, seccion: 'fase_grupos'),
                  notice: 'Partidos de fase de grupos generados correctamente.'
    else
      redirect_to torneo_path(@torneo, seccion: 'fase_grupos'),
                  alert: 'No se generaron partidos nuevos. Revise que los grupos tengan equipos suficientes.'
    end
  end

  def guardar_partidos_grupo
    grupo = @torneo.grupos.find(params[:grupo_id])
    datos_partidos = params[:partidos] || {}

    Partido.transaction do
      datos_partidos.each do |partido_id, datos|
        partido = grupo.partidos.find(partido_id)

        if datos[:jugado] == '1'
          partido.update!(
            goles_local: datos[:goles_local],
            goles_visitante: datos[:goles_visitante],
            estado: 'finalizado'
          )
        else
          partido.update!(
            goles_local: nil,
            goles_visitante: nil,
            estado: 'pendiente'
          )
        end
      end

      grupo.recalcular_estadisticas

      if @torneo.fase_grupos_completa?
        @torneo.update!(estado: 'eliminacion')
      else
        @torneo.update!(estado: 'grupos')
      end
    end

    redirect_to torneo_path(@torneo, seccion: 'fase_grupos'),
                notice: "Resultados del Grupo #{grupo.nombre} guardados correctamente."
  rescue ActiveRecord::RecordInvalid => e
    redirect_to torneo_path(@torneo, seccion: 'fase_grupos'),
                alert: "Error al guardar resultados: #{e.record.errors.full_messages.join(', ')}"
  end

  private

  def load_torneo
    @torneo = Torneo.find(params[:id])
  end

  def torneo_params
    params.require(:torneo).permit(:nombre, :tipo)
  end

  def crear_grupos_iniciales(torneo)
    if torneo.tipo == 'mundial'
      Grupo::NOMBRES_VALIDOS.each do |letra|
        torneo.grupos.create!(nombre: letra)
      end
    else
      torneo.grupos.create!(nombre: 'Bracket')
    end
  end

  def cargar_podio
    podio    = Partido.podio(@torneo)
    @primero = podio[:primero]
    @segundo = podio[:segundo]
    @tercero = podio[:tercero]
  end

  def cargar_clasificados
    @clasificados_directos = @torneo.clasificados_directos
    @mejores_terceros = @torneo.mejores_terceros
    @terceros_ordenados = @torneo.terceros_ordenados
    @clasificados_eliminatoria = @torneo.clasificados_eliminatoria
    @total_partidos_grupos = @torneo.total_partidos_fase_grupos
    @partidos_finalizados_grupos = @torneo.partidos_fase_grupos_finalizados
    @porcentaje_fase_grupos = @torneo.porcentaje_fase_grupos
    @fase_grupos_completa = @torneo.fase_grupos_completa?
  end
end
