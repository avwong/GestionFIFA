class Partido < ApplicationRecord
  self.table_name = "partidos"

  FASES = %w[fase_grupos dieciseisavos octavos cuartos semifinal tercer_lugar final].freeze
  ESTADOS = %w[pendiente en_curso finalizado].freeze

  ETIQUETAS_FASE = {
    "fase_grupos"    => "Fase de grupos",
    "dieciseisavos"  => "Dieciseisavos de final",
    "octavos"        => "Octavos de final",
    "cuartos"        => "Cuartos de final",
    "semifinal"      => "Semifinal",
    "tercer_lugar"   => "Tercer lugar",
    "final"          => "Final"
  }.freeze

  belongs_to :torneo, optional: true
  belongs_to :grupo, foreign_key: :grupo_id, optional: true
  belongs_to :equipo_local, class_name: "Equipo", foreign_key: :equipo_local_id
  belongs_to :equipo_visitante, class_name: "Equipo", foreign_key: :equipo_visitante_id
  belongs_to :siguiente_partido, class_name: "Partido", foreign_key: :siguiente_partido_id, optional: true

  validates :fase, presence: { message: "no puede estar vacía" },
                   inclusion: { in: FASES, message: "fase no válida" }
  validates :estado, inclusion: { in: ESTADOS, message: "estado no válido" }
  validate :equipos_distintos
  validate :grupo_requerido_en_fase_de_grupos

  def etiqueta_fase
    ETIQUETAS_FASE[fase]
  end

  def finalizado?
    estado == "finalizado"
  end

  def pendiente?
    estado == "pendiente"
  end

  # Determinar el ganador del partido
  def ganador
    return nil unless finalizado?

    if penales_local.present? && penales_visitante.present?
      penales_local > penales_visitante ? equipo_local : equipo_visitante
    elsif goles_extra_local.present? && goles_extra_visitante.present?
      total_local = (goles_local || 0) + goles_extra_local
      total_visitante = (goles_visitante || 0) + goles_extra_visitante
      total_local > total_visitante ? equipo_local : equipo_visitante
    else
      return nil if goles_local == goles_visitante
      goles_local > goles_visitante ? equipo_local : equipo_visitante
    end
  end

  def perdedor
    g = ganador
    return nil unless g
    g == equipo_local ? equipo_visitante : equipo_local
  end

  def self.podio(torneo = nil)
    scope  = torneo ? where(torneo: torneo) : all
    final  = scope.where(fase: "final",        estado: "finalizado").first
    tercer = scope.where(fase: "tercer_lugar", estado: "finalizado").first
    {
      primero: final&.ganador,
      segundo: final&.perdedor,
      tercero: tercer&.ganador
    }
  end

  # Registrar resultado y actualizar estadísticas de equipos en fase de grupos
  def registrar_resultado(gl, gv, extra_l: nil, extra_v: nil, pen_l: nil, pen_v: nil)
    self.goles_local = gl
    self.goles_visitante = gv
    self.goles_extra_local = extra_l
    self.goles_extra_visitante = extra_v
    self.penales_local = pen_l
    self.penales_visitante = pen_v
    self.estado = "finalizado"

    if fase == "fase_grupos"
      equipo_local.registrar_resultado(gl, gv)
      equipo_local.save!
      equipo_visitante.registrar_resultado(gv, gl)
      equipo_visitante.save!
    end

    save!
  end

  private

  def equipos_distintos
    if equipo_local_id.present? && equipo_visitante_id.present? && equipo_local_id == equipo_visitante_id
      errors.add(:base, "un equipo no puede jugar contra sí mismo")
    end
  end

  def grupo_requerido_en_fase_de_grupos
    if fase == "fase_grupos" && grupo.nil?
      errors.add(:grupo, "es obligatorio en la fase de grupos")
    end
  end
end
