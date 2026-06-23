class Group < ApplicationRecord
  VALID_NAMES = %w[A B C D E F G H I J K L].freeze

  has_many :teams, dependent: :nullify

  validates :name, presence: { message: "no puede estar vacío" },
                   uniqueness: { message: "ya existe" },
                   inclusion: { in: VALID_NAMES, message: "debe ser una letra entre A y L" }

  validate :maximo_cuatro_equipos

  # tabla de posiciones del grupo
  def standings
    teams.order("points DESC, (goals_for - goals_against) DESC, goals_for DESC")
  end

  # los dos que clasifican
  def qualifiers
    standings.first(2)
  end

  # el tercero (para elegir mejores terceros despues)
  def third_place_team
    standings.offset(2).first
  end

  private

  def maximo_cuatro_equipos
    if teams.size > 4
      errors.add(:base, "un grupo no puede tener más de 4 equipos")
    end
  end
end
