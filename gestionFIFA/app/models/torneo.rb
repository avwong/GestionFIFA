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
end
