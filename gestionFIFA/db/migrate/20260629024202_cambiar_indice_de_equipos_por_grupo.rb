class CambiarIndiceDeEquiposPorGrupo < ActiveRecord::Migration[8.1]
  def change
    remove_index :equipos, name: 'index_equipos_on_nombre', if_exists: true

    add_index :equipos, %i[grupo_id nombre],
              unique: true,
              name: 'index_equipos_on_grupo_id_and_nombre'
  end
end
