class Grupo < ApplicationRecord
  self.table_name = 'grupos'

  NOMBRES_VALIDOS = ('A'..'L').to_a.freeze

  belongs_to :torneo, optional: true
  has_many :equipos, foreign_key: :grupo_id, dependent: :destroy
  has_many :partidos, foreign_key: :grupo_id, dependent: :destroy

  validates :nombre, presence: { message: 'no puede estar vacío' },
                     uniqueness: { scope: :torneo_id, message: 'ya existe en este torneo' }
  validates :nombre, inclusion: { in: NOMBRES_VALIDOS, message: 'debe ser una letra entre A y L' },
                     if: -> { torneo&.tipo == 'mundial' }
  validate :maximo_cuatro_equipos

  # Tabla de posiciones ordenada por puntos, diferencia de goles, goles a favor
  def tabla_posiciones
    equipos.order(
      Arel.sql('puntos DESC, (goles_favor - goles_contra) DESC, goles_favor DESC, nombre ASC')
    )
  end

  # Los dos primeros clasificados del grupo
  def clasificados
    tabla_posiciones.first(2)
  end

  # El equipo en tercer lugar
  def tercer_lugar
    tabla_posiciones.offset(2).first
  end

  # Genera los partidos todos contra todos del grupo
  def generar_partidos_fase_grupos
    equipos_lista = equipos.order(:nombre).to_a

    equipos_lista.combination(2).each do |local, visitante|
      existe = partidos.where(fase: 'fase_grupos')
                       .where(
                         '(equipo_local_id = ? AND equipo_visitante_id = ?) OR (equipo_local_id = ? AND equipo_visitante_id = ?)',
                         local.id, visitante.id, visitante.id, local.id
                       )
                       .exists?

      next if existe

      partidos.create!(
        torneo: torneo,
        grupo: self,
        equipo_local: local,
        equipo_visitante: visitante,
        fase: 'fase_grupos',
        estado: 'pendiente'
      )
    end
  end

  # Recalcula la tabla del grupo usando los partidos finalizados
  def recalcular_estadisticas
    equipos.update_all(
      puntos: 0,
      partidos_jugados: 0,
      partidos_ganados: 0,
      partidos_empatados: 0,
      partidos_perdidos: 0,
      goles_favor: 0,
      goles_contra: 0,
      updated_at: Time.current
    )

    partidos.where(fase: 'fase_grupos', estado: 'finalizado').each do |partido|
      next if partido.goles_local.nil? || partido.goles_visitante.nil?

      local = Equipo.find(partido.equipo_local_id)
      visitante = Equipo.find(partido.equipo_visitante_id)

      local.registrar_resultado(partido.goles_local, partido.goles_visitante)
      visitante.registrar_resultado(partido.goles_visitante, partido.goles_local)

      local.save!
      visitante.save!
    end
  end

  # Elimina los partidos de fase de grupos donde participaba un equipo
  def limpiar_partidos_de_equipo(equipo_id)
    partidos.where(fase: 'fase_grupos')
            .where('equipo_local_id = ? OR equipo_visitante_id = ?', equipo_id, equipo_id)
            .destroy_all
  end

  private

  def maximo_cuatro_equipos
    return unless equipos.size > 4

    errors.add(:base, 'un grupo no puede tener más de 4 equipos')
  end
end
