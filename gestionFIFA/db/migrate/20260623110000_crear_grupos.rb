class CrearGrupos < ActiveRecord::Migration[8.1]
  def change
    create_table :grupos do |t|
      t.string :nombre, null: false

      t.timestamps
    end

    add_index :grupos, :nombre, unique: true
  end
end
