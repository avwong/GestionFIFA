class CreateTorneos < ActiveRecord::Migration[8.1]
  def change
    create_table :torneos do |t|
      t.string :nombre, null: false
      t.string :tipo,   null: false
      t.string :estado, null: false, default: "configuracion"

      t.timestamps
    end
    add_index :torneos, :nombre, unique: true
  end
end
