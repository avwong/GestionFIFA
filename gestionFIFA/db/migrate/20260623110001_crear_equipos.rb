class CrearEquipos < ActiveRecord::Migration[8.1]
  def change
    create_table :equipos do |t|
      t.string :nombre, null: false
      t.references :grupo, null: false, foreign_key: { to_table: :grupos }
      t.integer :puntos, null: false, default: 0
      t.integer :partidos_jugados, null: false, default: 0
      t.integer :partidos_ganados, null: false, default: 0
      t.integer :partidos_empatados, null: false, default: 0
      t.integer :partidos_perdidos, null: false, default: 0
      t.integer :goles_favor, null: false, default: 0
      t.integer :goles_contra, null: false, default: 0

      t.timestamps
    end

    add_index :equipos, :nombre, unique: true
  end
end
