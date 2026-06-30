puts "Limpiando datos anteriores..."
Partido.destroy_all
Equipo.destroy_all
Grupo.destroy_all
Torneo.destroy_all

GRUPOS_MUNDIAL_2026 = {
  "A" => ["México", "Sudáfrica", "República de Corea", "Chequia"],
  "B" => ["Canadá", "Bosnia y Herzegovina", "Catar", "Suiza"],
  "C" => ["Brasil", "Marruecos", "Haití", "Escocia"],
  "D" => ["Estados Unidos", "Paraguay", "Australia", "Turquía"],
  "E" => ["Alemania", "Curaçao", "Costa de Marfil", "Ecuador"],
  "F" => ["Países Bajos", "Japón", "Suecia", "Túnez"],
  "G" => ["Bélgica", "Egipto", "Irán", "Nueva Zelanda"],
  "H" => ["España", "Cabo Verde", "Arabia Saudí", "Uruguay"],
  "I" => ["Francia", "Senegal", "Irak", "Noruega"],
  "J" => ["Argentina", "Argelia", "Austria", "Jordania"],
  "K" => ["Portugal", "RD Congo", "Uzbekistán", "Colombia"],
  "L" => ["Inglaterra", "Croacia", "Ghana", "Panamá"]
}.freeze

CAMPEON = "Argentina".freeze

def marcador_aleatorio
  [rand(0..5), rand(0..5)]
end

def marcador_sin_empate
  loop do
    gl, gv = rand(0..4), rand(0..4)
    return [gl, gv] unless gl == gv
  end
end

def marcador_para(partido)
  es_local     = partido.equipo_local.nombre == CAMPEON
  es_visitante = partido.equipo_visitante.nombre == CAMPEON

  if es_local
    [rand(2..5), rand(0..1)]
  elsif es_visitante
    [rand(0..1), rand(2..5)]
  else
    marcador_sin_empate
  end
end

puts "Creando torneo Mundial 2026..."
torneo = Torneo.create!(nombre: "Mundial 2026", tipo: "mundial", estado: "configuracion")

puts "Creando grupos y equipos..."
GRUPOS_MUNDIAL_2026.each do |letra, paises|
  grupo = torneo.grupos.create!(nombre: letra)
  paises.each { |pais| grupo.equipos.create!(nombre: pais) }
  puts "  Grupo #{letra}: #{paises.join(', ')}"
end

puts ""
puts "Generando partidos de fase de grupos..."
torneo.grupos.each(&:generar_partidos_fase_grupos)
puts "  #{torneo.partidos.where(fase: 'fase_grupos').count} partidos generados"

puts ""
puts "Registrando resultados aleatorios en fase de grupos..."
torneo.partidos.where(fase: 'fase_grupos').each do |partido|
  involucra_campeon = [partido.equipo_local.nombre, partido.equipo_visitante.nombre].include?(CAMPEON)
  gl, gv = involucra_campeon ? marcador_para(partido) : marcador_aleatorio
  partido.registrar_resultado(gl, gv)
end
puts "  Todos los partidos de fase de grupos finalizados"

puts ""
puts "Tabla de clasificados por grupo:"
torneo.grupos.order(:nombre).each do |grupo|
  clasificados = grupo.clasificados.map(&:nombre).join(', ')
  tercero = grupo.tercer_lugar&.nombre || 'N/A'
  puts "  Grupo #{grupo.nombre}: 1°/2° => #{clasificados} | 3° => #{tercero}"
end

puts ""
puts "Generando bracket de eliminación directa..."
torneo.reload
resultado = torneo.generar_bracket_eliminacion

unless resultado
  puts "ERROR: No se pudo generar el bracket. Clasificados: #{torneo.clasificados_rankeados.count}"
  exit 1
end

puts "  Bracket generado. Torneo estado: #{torneo.estado}"

puts ""
puts "Jugando ronda de dieciseisavos de final..."
(1..16).each_slice(2) do |num1, num2|
  [num1, num2].each do |num|
    partido = torneo.partidos.find_by(fase: 'dieciseisavos', numero_partido: num)
    gl, gv = marcador_para(partido)
    partido.registrar_resultado(gl, gv)
    torneo.actualizar_llaves_desde(partido)
    puts "  Partido #{num}: #{partido.equipo_local.nombre} #{gl} - #{gv} #{partido.equipo_visitante.nombre}"
  end
end

puts ""
puts "Jugando octavos de final..."
(17..24).each_slice(2) do |num1, num2|
  [num1, num2].each do |num|
    partido = torneo.partidos.find_by(fase: 'octavos', numero_partido: num)
    next unless partido

    gl, gv = marcador_para(partido)
    partido.registrar_resultado(gl, gv)
    torneo.actualizar_llaves_desde(partido)
    puts "  Partido #{num}: #{partido.equipo_local.nombre} #{gl} - #{gv} #{partido.equipo_visitante.nombre}"
  end
end

puts ""
puts "Jugando cuartos de final..."
(25..28).each_slice(2) do |num1, num2|
  [num1, num2].each do |num|
    partido = torneo.partidos.find_by(fase: 'cuartos', numero_partido: num)
    next unless partido

    gl, gv = marcador_para(partido)
    partido.registrar_resultado(gl, gv)
    torneo.actualizar_llaves_desde(partido)
    puts "  Partido #{num}: #{partido.equipo_local.nombre} #{gl} - #{gv} #{partido.equipo_visitante.nombre}"
  end
end

puts ""
puts "Jugando semifinales..."
[29, 30].each do |num|
  partido = torneo.partidos.find_by(fase: 'semifinal', numero_partido: num)
  next unless partido

  gl, gv = marcador_para(partido)
  partido.registrar_resultado(gl, gv)
  torneo.actualizar_llaves_desde(partido)
  puts "  Partido #{num}: #{partido.equipo_local.nombre} #{gl} - #{gv} #{partido.equipo_visitante.nombre}"
end

puts ""
puts "Jugando tercer lugar..."
partido_tercero = torneo.partidos.find_by(fase: 'tercer_lugar', numero_partido: 31)
if partido_tercero
  gl, gv = marcador_para(partido_tercero)
  partido_tercero.registrar_resultado(gl, gv)
  puts "  Partido 31 (#{partido_tercero.etiqueta_fase}): #{partido_tercero.equipo_local.nombre} #{gl} - #{gv} #{partido_tercero.equipo_visitante.nombre}"
end

puts ""
final = torneo.partidos.find_by(fase: 'final', numero_partido: 32)
puts "=== FINAL PENDIENTE ==="
puts "  #{final.equipo_local.nombre} vs #{final.equipo_visitante.nombre} (aún no jugada)"

puts ""
puts "=" * 50

GRUPOS_COPA_AMERICANA = {
  "A" => ["Argentina", "Chile", "Perú", "Bolivia"],
  "B" => ["Brasil", "Colombia", "Ecuador", "Venezuela"],
  "C" => ["Uruguay", "Paraguay", "Guyana", "Surinam"],
  "D" => ["México", "Estados Unidos", "Canadá", "Costa Rica"],
  "E" => ["Panamá", "Honduras", "El Salvador", "Guatemala"],
  "F" => ["Jamaica", "Haití", "Trinidad y Tobago", "Cuba"],
  "G" => ["República Dominicana", "Nicaragua", "Belice", "Guadalupe"],
  "H" => ["Martinica", "Curaçao", "Puerto Rico", "Aruba"],
  "I" => ["Bahamas", "Bermuda", "Granada", "Barbados"],
  "J" => ["Santa Lucía", "San Vicente", "Dominica", "Antigua"],
  "K" => ["Guayana Francesa", "Montserrat", "Islas Caimán", "Islas Vírgenes"],
  "L" => ["San Cristóbal", "Anguila", "Islas Turcas", "Belice B"]
}.freeze

puts "Creando torneo Copa Americana..."
copa = Torneo.create!(nombre: "Copa Americana", tipo: "mundial", estado: "grupos")

puts "Creando grupos y equipos..."
GRUPOS_COPA_AMERICANA.each do |letra, paises|
  grupo = copa.grupos.create!(nombre: letra)
  paises.each { |pais| grupo.equipos.create!(nombre: pais) }
  puts "  Grupo #{letra}: #{paises.join(', ')}"
end

puts ""
puts "Generando partidos de fase de grupos..."
copa.grupos.each(&:generar_partidos_fase_grupos)
total_copa = copa.partidos.where(fase: 'fase_grupos').count
puts "  #{total_copa} partidos generados"

puts ""
puts "Registrando resultados (todos menos el último)..."
partidos_copa = copa.partidos.where(fase: 'fase_grupos').order(:id).to_a
partidos_copa[0..-2].each { |p| p.registrar_resultado(*marcador_aleatorio) }

ultimo = partidos_copa.last
puts "  #{total_copa - 1} partidos jugados"
puts ""
puts "=== PARTIDO PENDIENTE COPA AMERICANA ==="
puts "  #{ultimo.equipo_local.nombre} vs #{ultimo.equipo_visitante.nombre} (aún no jugado)"

puts ""
puts "  Seed completo:"
puts "  #{Torneo.count} torneos | #{Grupo.count} grupos | #{Equipo.count} equipos"
puts "  Mundial 2026  — #{torneo.partidos.where(estado: 'finalizado').count} finalizados | 1 partido pendiente (final)"
puts "  Copa Americana — #{copa.partidos.where(estado: 'finalizado').count}/#{total_copa} fase grupos | 1 partido pendiente"
