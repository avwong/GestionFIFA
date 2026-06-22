class CreateTeams < ActiveRecord::Migration[8.1]
  def change
    create_table :teams do |t|
      t.string :name, null: false
      t.string :group_name, null: false
      t.integer :points, null: false, default: 0
      t.integer :goals_for, null: false, default: 0
      t.integer :goals_against, null: false, default: 0
      t.integer :matches_played, null: false, default: 0
      t.integer :wins, null: false, default: 0
      t.integer :draws, null: false, default: 0
      t.integer :losses, null: false, default: 0

      t.timestamps
    end

    # nombres unicos, busquedas por grupo
    add_index :teams, :name, unique: true
    add_index :teams, :group_name
  end
end
