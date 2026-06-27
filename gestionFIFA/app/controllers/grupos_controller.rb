class GruposController < ApplicationController
  skip_forgery_protection

  def index
    @grupos = Grupo.includes(:equipos).order(:nombre)
  end

  def create
    @grupo = Grupo.new(grupo_params)
    if @grupo.save
      redirect_to grupos_path, notice: "Grupo #{@grupo.nombre} creado correctamente."
    else
      redirect_to grupos_path, alert: "Error al crear el grupo: #{@grupo.errors.full_messages.join(', ')}"
    end
  end

  def update
    @grupo = Grupo.find(params[:id])
    nombre_viejo = @grupo.nombre
    if @grupo.update(grupo_params)
      redirect_to grupos_path, notice: "Grupo #{nombre_viejo} renombrado a Grupo #{@grupo.nombre}."
    else
      redirect_to grupos_path, alert: "Error al actualizar el grupo: #{@grupo.errors.full_messages.join(', ')}"
    end
  end

  def destroy
    @grupo = Grupo.find(params[:id])
    nombre = @grupo.nombre
    equipos_count = @grupo.equipos.count
    @grupo.destroy
    msg = "Grupo #{nombre} eliminado."
    msg += " Se eliminaron también #{equipos_count} equipo(s) asociado(s)." if equipos_count > 0
    redirect_to grupos_path, notice: msg
  end

  private

  def grupo_params
    params.require(:grupo).permit(:nombre)
  end
end
