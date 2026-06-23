class CrearPartidos < ActiveRecord::Migration[8.1]
  def change
    create_table :partidos do |t|
      t.references :grupo, null: true, foreign_key: { to_table: :grupos }
      t.references :equipo_local, null: false, foreign_key: { to_table: :equipos }
      t.references :equipo_visitante, null: false, foreign_key: { to_table: :equipos }
      t.integer :goles_local
      t.integer :goles_visitante
      t.integer :goles_extra_local
      t.integer :goles_extra_visitante
      t.integer :penales_local
      t.integer :penales_visitante
      t.string :fase, null: false
      t.string :estado, null: false, default: "pendiente"
      t.integer :numero_partido
      t.references :siguiente_partido, null: true, foreign_key: { to_table: :partidos }

      t.timestamps
    end
  end
end
