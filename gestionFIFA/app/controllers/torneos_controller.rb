class TorneosController < ApplicationController
  before_action :load_torneo, only: %i[show edit update destroy]

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
    @grupos  = @torneo.grupos.includes(:equipos).order(:nombre)
    cargar_podio if @seccion == 'podio'
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
end
