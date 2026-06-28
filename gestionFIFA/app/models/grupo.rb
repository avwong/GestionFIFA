class Grupo < ApplicationRecord
  self.table_name = "grupos"

  NOMBRES_VALIDOS = ("A".."L").to_a.freeze

  belongs_to :torneo, optional: true
  has_many :equipos, foreign_key: :grupo_id, dependent: :destroy
  has_many :partidos, foreign_key: :grupo_id, dependent: :destroy

  validates :nombre, presence: { message: "no puede estar vacío" },
                     uniqueness: { scope: :torneo_id, message: "ya existe en este torneo" }
  validates :nombre, inclusion: { in: NOMBRES_VALIDOS, message: "debe ser una letra entre A y L" },
                     if: -> { torneo&.tipo == "mundial" }
  validate :maximo_cuatro_equipos

  # Tabla de posiciones ordenada por puntos, diferencia de goles, goles a favor
  def tabla_posiciones
    equipos.order(
      Arel.sql("puntos DESC, (goles_favor - goles_contra) DESC, goles_favor DESC, nombre ASC")
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

  private

  def maximo_cuatro_equipos
    if equipos.size > 4
      errors.add(:base, "un grupo no puede tener más de 4 equipos")
    end
  end
end
