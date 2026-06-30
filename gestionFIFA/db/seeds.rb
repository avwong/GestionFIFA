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

puts "Creando torneo Mundial 2026..."
torneo = Torneo.create!(nombre: "Mundial 2026", tipo: "mundial", estado: "configuracion")

puts "Creando grupos y equipos..."
GRUPOS_MUNDIAL_2026.each do |letra, paises|
  grupo = torneo.grupos.create!(nombre: letra)

  paises.each do |pais|
    grupo.equipos.create!(nombre: pais)
  end

  puts "  Grupo #{letra}: #{paises.join(', ')}"
end

puts ""
puts "✓ Seed completado: #{Torneo.count} torneo, #{Grupo.count} grupos, #{Equipo.count} equipos."
