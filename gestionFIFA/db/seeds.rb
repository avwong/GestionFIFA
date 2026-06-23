puts "Limpiando datos anteriores..."
Partido.destroy_all if defined?(Partido)
Equipo.destroy_all if defined?(Equipo)
Grupo.destroy_all if defined?(Grupo)

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
}

puts "Creando grupos y equipos del Mundial 2026..."

GRUPOS_MUNDIAL_2026.each do |letra, paises|
  grupo = Grupo.create!(nombre: letra)

  paises.each do |pais|
    Equipo.create!(nombre: pais, grupo: grupo)
  end

  puts "  Grupo #{letra}: #{paises.join(', ')}"
end

puts ""
puts "✓ Seed completado: #{Grupo.count} grupos, #{Equipo.count} equipos."
