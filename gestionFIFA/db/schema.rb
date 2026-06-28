# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_06_28_211924) do
  create_table "equipos", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "goles_contra", default: 0, null: false
    t.integer "goles_favor", default: 0, null: false
    t.integer "grupo_id", null: false
    t.string "nombre", null: false
    t.integer "partidos_empatados", default: 0, null: false
    t.integer "partidos_ganados", default: 0, null: false
    t.integer "partidos_jugados", default: 0, null: false
    t.integer "partidos_perdidos", default: 0, null: false
    t.integer "puntos", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["grupo_id"], name: "index_equipos_on_grupo_id"
    t.index ["nombre"], name: "index_equipos_on_nombre", unique: true
  end

  create_table "grupos", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "nombre", null: false
    t.integer "torneo_id"
    t.datetime "updated_at", null: false
    t.index ["nombre"], name: "index_grupos_on_nombre", unique: true
    t.index ["torneo_id"], name: "index_grupos_on_torneo_id"
  end

  create_table "partidos", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "equipo_local_id", null: false
    t.integer "equipo_visitante_id", null: false
    t.string "estado", default: "pendiente", null: false
    t.string "fase", null: false
    t.integer "goles_extra_local"
    t.integer "goles_extra_visitante"
    t.integer "goles_local"
    t.integer "goles_visitante"
    t.integer "grupo_id"
    t.integer "numero_partido"
    t.integer "penales_local"
    t.integer "penales_visitante"
    t.integer "siguiente_partido_id"
    t.integer "torneo_id"
    t.datetime "updated_at", null: false
    t.index ["equipo_local_id"], name: "index_partidos_on_equipo_local_id"
    t.index ["equipo_visitante_id"], name: "index_partidos_on_equipo_visitante_id"
    t.index ["grupo_id"], name: "index_partidos_on_grupo_id"
    t.index ["siguiente_partido_id"], name: "index_partidos_on_siguiente_partido_id"
    t.index ["torneo_id"], name: "index_partidos_on_torneo_id"
  end

  create_table "torneos", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "estado", default: "configuracion", null: false
    t.string "nombre", null: false
    t.string "tipo", null: false
    t.datetime "updated_at", null: false
    t.index ["nombre"], name: "index_torneos_on_nombre", unique: true
  end

  add_foreign_key "equipos", "grupos"
  add_foreign_key "grupos", "torneos"
  add_foreign_key "partidos", "equipos", column: "equipo_local_id"
  add_foreign_key "partidos", "equipos", column: "equipo_visitante_id"
  add_foreign_key "partidos", "grupos"
  add_foreign_key "partidos", "partidos", column: "siguiente_partido_id"
  add_foreign_key "partidos", "torneos"
end
