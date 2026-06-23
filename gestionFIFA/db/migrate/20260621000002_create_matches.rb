class CreateMatches < ActiveRecord::Migration[8.1]
  def change
    create_table :matches do |t|
      t.references :home_team, null: false, foreign_key: { to_table: :teams }
      t.references :away_team, null: false, foreign_key: { to_table: :teams }
      t.references :group, null: true, foreign_key: true
      t.string :phase, null: false
      t.integer :home_goals
      t.integer :away_goals
      t.integer :home_extra_goals
      t.integer :away_extra_goals
      t.boolean :played, null: false, default: false

      t.timestamps
    end
  end
end
