class Team < ApplicationRecord
  belongs_to :group

  validates :name, presence: { message: "no puede estar vacío" },
                   uniqueness: { message: "ya está registrado" }
  validates :points, :goals_for, :goals_against,
            :matches_played, :wins, :draws, :losses,
            numericality: { only_integer: true, greater_than_or_equal_to: 0,
                            message: "debe ser un número entero no negativo" }

  # no se guarda, siempre se calcula
  def goal_difference
    goals_for - goals_against
  end

  # actualiza estadisticas segun el resultado de un partido
  def record_match_result(goals_scored, goals_conceded)
    self.matches_played += 1
    self.goals_for += goals_scored
    self.goals_against += goals_conceded

    if goals_scored > goals_conceded
      self.wins += 1
      self.points += 3
    elsif goals_scored == goals_conceded
      self.draws += 1
      self.points += 1
    else
      self.losses += 1
    end
  end

  # orden FIFA: puntos, diferencia, goles
  scope :standings, -> {
    order("points DESC, (goals_for - goals_against) DESC, goals_for DESC")
  }

  # mejores terceros para el repechaje
  def self.best_third_place_teams(n = 8)
    Group::VALID_NAMES.filter_map { |name|
      Group.find_by(name: name)&.third_place_team
    }.sort_by { |t| [-t.points, -t.goal_difference, -t.goals_for] }.first(n)
  end
end
