class CambiarIndiceDeGruposPorTorneo < ActiveRecord::Migration[8.1]
  def change
    remove_index :grupos, name: 'index_grupos_on_nombre', if_exists: true

    add_index :grupos, %i[torneo_id nombre],
              unique: true,
              name: 'index_grupos_on_torneo_id_and_nombre'
  end
end
