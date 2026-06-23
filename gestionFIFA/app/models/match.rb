class Match < ApplicationRecord
  PHASES = %w[group round_of_32 round_of_16 quarter_final semi_final third_place final].freeze

  PHASE_LABELS = {
    "group"        => "Fase de grupos",
    "round_of_32"  => "Dieciseisavos de final",
    "round_of_16"  => "Octavos de final",
    "quarter_final" => "Cuartos de final",
    "semi_final"   => "Semifinal",
    "third_place"  => "Tercer lugar",
    "final"        => "Final"
  }.freeze

  belongs_to :home_team, class_name: "Team"
  belongs_to :away_team, class_name: "Team"
  belongs_to :group, optional: true

  validates :phase, presence: { message: "no puede estar vacío" },
                    inclusion: { in: PHASES, message: "fase no válida" }
  validates :home_goals, :away_goals,
            numericality: { only_integer: true, greater_than_or_equal_to: 0,
                            message: "debe ser un número entero no negativo" },
            allow_nil: true
  validates :home_extra_goals, :away_extra_goals,
            numericality: { only_integer: true, greater_than_or_equal_to: 0,
                            message: "debe ser un número entero no negativo" },
            allow_nil: true

  validate :equipos_distintos
  validate :grupo_requerido_en_fase_de_grupos
  validate :penales_solo_si_hubo_empate

  # nombre legible de la fase
  def phase_label
    PHASE_LABELS[phase]
  end

  def played?
    played
  end

  def tied_in_regular_time?
    played? && home_goals == away_goals
  end

  # hubo tiempo extra / penales
  def went_to_penalties?
    home_extra_goals.present? && away_extra_goals.present?
  end

  # si empate en fase de grupos
  def winner
    return nil unless played?

    if home_goals > away_goals
      home_team
    elsif away_goals > home_goals
      away_team
    elsif went_to_penalties?
      home_extra_goals > away_extra_goals ? home_team : away_team
    end
  end

  def loser
    return nil unless played?
    return nil if winner.nil?
    winner == home_team ? away_team : home_team
  end

  # registra el resultado y actualiza estadisticas de ambos equipos
  def register_result(home_scored, away_scored, home_extra: nil, away_extra: nil)
    self.home_goals = home_scored
    self.away_goals = away_scored
    self.home_extra_goals = home_extra
    self.away_extra_goals = away_extra
    self.played = true

    if phase == "group"
      home_team.record_match_result(home_scored, away_scored)
      away_team.record_match_result(away_scored, home_scored)
      home_team.save!
      away_team.save!
    end

    save!
  end

  private

  def equipos_distintos
    if home_team_id == away_team_id
      errors.add(:base, "un equipo no puede jugar contra sí mismo")
    end
  end

  def grupo_requerido_en_fase_de_grupos
    if phase == "group" && group.nil?
      errors.add(:group, "es obligatorio en la fase de grupos")
    end
  end

  def penales_solo_si_hubo_empate
    if went_to_penalties? && !tied_in_regular_time?
      errors.add(:base, "solo puede haber penales si hubo empate en tiempo regular")
    end
  end
end
