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

  def partidos_eliminacion
    partidos.where(fase: %w[dieciseisavos octavos cuartos semifinal tercer_lugar final])
  end

  def clasificados_rankeados
    clasificados_eliminatoria.sort_by do |equipo|
      [-equipo.puntos, -equipo.diferencia_de_goles, -equipo.goles_favor, equipo.nombre]
    end
  end

  def generar_bracket_eliminacion
    equipos_clasificados = clasificados_rankeados
    return false unless equipos_clasificados.count == 32
    return false if partidos_eliminacion.exists?

    16.times do |i|
      partidos.create!(
        equipo_local: equipos_clasificados[i],
        equipo_visitante: equipos_clasificados[31 - i],
        fase: 'dieciseisavos',
        estado: 'pendiente',
        numero_partido: i + 1
      )
    end

    update!(estado: 'eliminacion')
    true
  end

  def actualizar_llaves_desde(partido)
    return unless partido.finalizado?

    case partido.fase
    when 'dieciseisavos'
      actualizar_ronda_siguiente(partido, 'dieciseisavos', 'octavos', 1, 17)
    when 'octavos'
      actualizar_ronda_siguiente(partido, 'octavos', 'cuartos', 17, 25)
    when 'cuartos'
      actualizar_ronda_siguiente(partido, 'cuartos', 'semifinal', 25, 29)
    when 'semifinal'
      actualizar_final_y_tercer_lugar
    end
  end

  private

  def actualizar_ronda_siguiente(partido, fase_origen, fase_destino, inicio_origen, inicio_destino)
    numero_base = partido.numero_partido.odd? ? partido.numero_partido : partido.numero_partido - 1
    numero_destino = inicio_destino + ((numero_base - inicio_origen) / 2)

    partidos_origen = partidos.where(fase: fase_origen, numero_partido: [numero_base, numero_base + 1])
                              .order(:numero_partido)

    crear_o_actualizar_partido_destino(fase_destino, numero_destino, partidos_origen)
  end

  def actualizar_final_y_tercer_lugar
    semifinales = partidos.where(fase: 'semifinal', numero_partido: [29, 30]).order(:numero_partido)

    crear_o_actualizar_partido_destino('final', 32, semifinales)
    crear_o_actualizar_partido_destino('tercer_lugar', 31, semifinales, usar_perdedores: true)
  end

  def crear_o_actualizar_partido_destino(fase_destino, numero_destino, partidos_origen, usar_perdedores: false)
    equipos = partidos_origen.map do |partido|
      usar_perdedores ? partido.perdedor : partido.ganador
    end

    return unless equipos.size == 2 && equipos.all?

    partido_destino = partidos.find_by(fase: fase_destino, numero_partido: numero_destino)

    if partido_destino
      equipos_cambiaron = partido_destino.equipo_local_id != equipos[0].id ||
                          partido_destino.equipo_visitante_id != equipos[1].id

      datos = {
        equipo_local: equipos[0],
        equipo_visitante: equipos[1]
      }

      if equipos_cambiaron
        datos.merge!(
          goles_local: nil,
          goles_visitante: nil,
          goles_extra_local: nil,
          goles_extra_visitante: nil,
          penales_local: nil,
          penales_visitante: nil,
          estado: 'pendiente'
        )
      end

      partido_destino.update!(datos)
    else
      partidos.create!(
        equipo_local: equipos[0],
        equipo_visitante: equipos[1],
        fase: fase_destino,
        estado: 'pendiente',
        numero_partido: numero_destino
      )
    end
  end
end
