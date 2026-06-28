class AddTorneoIdToGrupos < ActiveRecord::Migration[8.1]
  def change
    add_reference :grupos, :torneo, null: true, foreign_key: true
  end
end
