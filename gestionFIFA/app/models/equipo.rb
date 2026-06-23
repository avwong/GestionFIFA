class Equipo < ApplicationRecord
  self.table_name = "equipos"

  belongs_to :grupo, foreign_key: :grupo_id

  has_many :partidos_local, class_name: "Partido", foreign_key: :equipo_local_id, dependent: :destroy
  has_many :partidos_visitante, class_name: "Partido", foreign_key: :equipo_visitante_id, dependent: :destroy

  validates :nombre, presence: { message: "no puede estar vacío" },
                     uniqueness: { message: "ya está registrado" }
  validates :puntos, :goles_favor, :goles_contra, :partidos_jugados,
            :partidos_ganados, :partidos_empatados, :partidos_perdidos,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # Diferencia de goles (calculada, no almacenada)
  def diferencia_de_goles
    goles_favor - goles_contra
  end

  # Registrar el resultado de un partido de fase de grupos
  def registrar_resultado(goles_anotados, goles_recibidos)
    self.partidos_jugados += 1
    self.goles_favor += goles_anotados
    self.goles_contra += goles_recibidos

    if goles_anotados > goles_recibidos
      self.partidos_ganados += 1
      self.puntos += 3
    elsif goles_anotados == goles_recibidos
      self.partidos_empatados += 1
      self.puntos += 1
    else
      self.partidos_perdidos += 1
    end
  end

  # Obtener los 8 mejores terceros lugares de todos los grupos
  def self.mejores_terceros(grupos, cantidad = 8)
    terceros = grupos.map { |g| g.tercer_lugar }.compact
    terceros.sort_by { |e| [-e.puntos, -e.diferencia_de_goles, -e.goles_favor] }
            .first(cantidad)
  end
end
