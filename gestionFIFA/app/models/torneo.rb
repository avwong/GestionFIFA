class Torneo < ApplicationRecord
  TIPOS   = %w[mundial bracket].freeze
  ESTADOS = %w[configuracion grupos eliminacion finalizado].freeze

  has_many :grupos,   dependent: :destroy
  has_many :partidos, dependent: :destroy
  has_many :equipos,  through: :grupos

  validates :nombre, presence: true, uniqueness: true
  validates :tipo,   inclusion: { in: TIPOS }
  validates :estado, inclusion: { in: ESTADOS }

  def equipos_count
    equipos.count
  end

  def partidos_fase_grupos
    partidos.where(fase: 'fase_grupos')
  end

  def total_partidos_fase_grupos
    partidos_fase_grupos.count
  end

  def partidos_fase_grupos_finalizados
    partidos_fase_grupos.where(estado: 'finalizado').count
  end

  def porcentaje_fase_grupos
    total = total_partidos_fase_grupos
    return 0 if total.zero?

    ((partidos_fase_grupos_finalizados.to_f / total) * 100).round
  end

  def fase_grupos_completa?
    total = total_partidos_fase_grupos
    total.positive? && partidos_fase_grupos_finalizados == total
  end

  def clasificados_directos
    grupos.order(:nombre).flat_map do |grupo|
      grupo.clasificados
    end.compact
  end

  def terceros_ordenados
    terceros = grupos.includes(:equipos).map(&:tercer_lugar).compact

    terceros.sort_by do |equipo|
      [-equipo.puntos, -equipo.diferencia_de_goles, -equipo.goles_favor, equipo.nombre]
    end
  end

  def mejores_terceros(cantidad = 8)
    terceros_ordenados.first(cantidad)
  end

  def clasificados_eliminatoria
    (clasificados_directos + mejores_terceros).compact
  end
end
